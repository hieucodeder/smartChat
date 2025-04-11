import 'package:chatbotbnn/model/body_chatbot_answer.dart';
import 'package:chatbotbnn/model/chatbot_config.dart';
import 'package:chatbotbnn/model/history_all_model.dart';
import 'package:chatbotbnn/provider/chat_provider.dart';
import 'package:chatbotbnn/provider/chatbot_provider.dart';
import 'package:chatbotbnn/provider/historyid_provider.dart';
import 'package:chatbotbnn/provider/platform_provider.dart';
import 'package:chatbotbnn/provider/provider_color.dart';
import 'package:chatbotbnn/service/anwser_number.dart';
import 'package:chatbotbnn/service/chatbot_config_service.dart';
import 'package:chatbotbnn/service/history_all_service.dart';
import 'package:chatbotbnn/service/history_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  final String historyId;

  const ChatPage({
    super.key,
    required this.historyId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  String? _initialMessage;
  bool _isLoading = false;
  late HistoryidProvider _historyidProvider;
  ChatProvider? _chatProvider;
  List<String> _suggestions = [];
  late Future<HistoryAllModel> _historyAllModel;

  String platform = ''; // Khởi tạo platform rỗng
  @override
  void initState() {
    super.initState();
    // _loadInitialMessage();
    _historyidProvider = Provider.of<HistoryidProvider>(context, listen: false);
    _historyidProvider.addListener(fetchAndUpdateChatHistory);
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    Provider.of<ChatProvider>(context, listen: false)
        .loadInitialMessage(context);
    loadChatbotConfig();
    // _fetchHistoryAllModel(context);
  }

  @override
  void dispose() {
    // stopPatrolling(context);
    _historyidProvider.removeListener(fetchAndUpdateChatHistory);
    super.dispose();
  }

  void _fetchHistoryAllModel(BuildContext context) async {
    final chatbotCode = context.read<ChatbotProvider>().currentChatbotCode;
    final historyidProvider = context.read<HistoryidProvider>();

    try {
      final historyAllModel = await fetchChatHistoryAll(chatbotCode, "", "");

      if (historyAllModel.data != null && historyAllModel.data!.isNotEmpty) {
        final chatbotHistoryId =
            historyAllModel.data![0].chatbotHistoryId?.toString() ?? "";
        print('Lich su khi chua co id: $chatbotHistoryId');

        // Cập nhật ID mà không gọi notifyListeners()
        historyidProvider.setChatbotHistoryIdWithoutNotify(chatbotHistoryId);
      }
    } catch (e) {
      print("Error fetching chat history: $e");
    }
  }

  Future<DataConfig?> loadChatbotConfig() async {
    final chatbotCode =
        Provider.of<ChatbotProvider>(context, listen: false).currentChatbotCode;

    try {
      List<DataConfig> chatbotConfig = await fetchChatbotConfig(chatbotCode!);

      if (chatbotConfig.isEmpty) {
        throw Exception('❌ Không tìm thấy cấu hình chatbot.');
      }

      final config = chatbotConfig.first;
      return config;
    } catch (error) {
      debugPrint("❌ Lỗi khi tải cấu hình chatbot: $error");
      return null;
    }
  }

  void _sendMessage() async {
    setState(() {
      _isLoading = true;
      platform = ''; // Xóa platform khi bắt đầu gửi
    });

    final chatbotCode =
        Provider.of<ChatbotProvider>(context, listen: false).currentChatbotCode;
    final historyId =
        Provider.of<HistoryidProvider>(context, listen: false).chatbotHistoryId;
    if (chatbotCode == null) {
      return;
    }

    if (_controller.text.trim().isEmpty) {
      return;
    }

    String userQuery = _controller.text.trim();
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userid');
    String chatbotName =
        prefs.getString('chatbot_name') ?? 'Default Chatbot Name';

    if (userId == null) {
      return;
    }

    setState(() {
      _messages.insert(0, {'type': 'user', 'text': userQuery});
      _isLoading = true;
    });

    _controller.clear();
    // Lấy cấu hình chatbot
    DataConfig? chatbotConfig = await loadChatbotConfig();

    if (chatbotConfig == null) {
      debugPrint("⚠️ Không thể tải cấu hình chatbot.");
      return;
    }

    bool isNewSession = historyId.isEmpty;

    BodyChatbotAnswer chatbotRequest = BodyChatbotAnswer(
      chatbotCode: chatbotConfig.chatbotCode ?? '',
      chatbotName: chatbotConfig.chatbotName ?? '',
      collectionName: chatbotConfig.collectionName ?? '',
      customizePrompt: chatbotConfig.promptContent ?? '',
      fallbackResponse: chatbotConfig.fallbackResponse ?? '',
      genModel: chatbotConfig.modelGenerate ?? '',
      history: (chatbotConfig.history == null || chatbotConfig.history!.isEmpty)
          ? ''
          : "",
      historyId: isNewSession ? "" : historyId,
      intentQueue: [],
      // isNewSession: isNewSession,
      language: "Vietnamese",
      platform: "",
      query: userQuery,
      rerankModel: chatbotConfig.modelRerank ?? '',
      rewriteModel: chatbotConfig.queryRewrite ?? '',
      slots: [],
      slotsConfig: [],
      systemPrompt: chatbotConfig.systemPrompt ?? '',
      temperature: chatbotConfig.temperature ?? 0,
      threadHold: chatbotConfig.threadHold ?? 0.8,
      topCount: chatbotConfig.topCount ?? 3,
      type: "normal",
      userId: userId,
      userIndustry: "",
    );

    String? response;

    List<Map<String, dynamic>>? table;
    List<dynamic> images = [];

    response = await fetchApiResponseNumber(
      chatbotRequest,
      setState,
      _messages,
      (extraData) {
        if (extraData is List<String> && extraData.isNotEmpty) {
          setState(() {});
        }
      },
    );

    if (historyId.isEmpty) {
      //gọi hàm mà không cập nhật UI
      Future.microtask(() => _fetchHistoryAllModel(context));
    }

    setState(() {
      _isLoading = false;
      final historyidProvider =
          Provider.of<HistoryidProvider>(context, listen: false);
      String historyId = historyidProvider.chatbotHistoryId;
      if (response != null) {
        if (_messages.isEmpty ||
            (_messages[0]['type'] == 'bot' &&
                _messages[0]['text'] == 'response')) {
          _messages[0]['table'] = table;

          // Kiểm tra dữ liệu ảnh trước khi thêm vào danh sách tin nhắn
          if (images.isNotEmpty && images.every((img) => img is String)) {
            _messages[0]['imageStatistic'] = images;
          } else {
            _messages[0]['imageStatistic'] = [];
          }
        } else {
          _messages.insert(0, {
            'type': 'bot',
            'text': '',
            'table': table,
            'imageStatistic':
                images.isNotEmpty && images.every((img) => img is String)
                    ? images
                    : [],
          });

          if (historyId.isEmpty) {
            //gọi hàm mà không cập nhật UI
            Future.microtask(() => _fetchHistoryAllModel(context));
          }
          // Cuộn xuống cuối cùng sau khi danh sách tin nhắn cập nhật
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }
      }
    });
  }

  Future<void> fetchAndUpdateChatHistory() async {
    if (!mounted) return;

    final historyidProvider =
        Provider.of<HistoryidProvider>(context, listen: false);
    final newHistoryId = historyidProvider.chatbotHistoryId;

    if (newHistoryId.isEmpty) {
      debugPrint("⚠️ No chatbot history ID available.");
      return;
    }

    if (_messages.isNotEmpty &&
        historyidProvider.previousHistoryId == newHistoryId) {
      debugPrint("🔄 No changes in history ID, skipping fetch.");
      return;
    }

    try {
      debugPrint("📡 Fetching chat history for ID: $newHistoryId");
      List<Map<String, dynamic>> contents =
          await fetchChatHistory(newHistoryId);

      if (!mounted) return;

      setState(() {
        _messages.clear();

        for (var content in contents) {
          List<String> images = [];
          List<Map<String, dynamic>>? tableData = content['table'];
          List<String> suggestions =
              List<String>.from(content['suggestions'] ?? []);

          // Xử lý dữ liệu ảnh nếu có
          if (content.containsKey('imageStatistic')) {
            if (content['imageStatistic'] is List) {
              images = List<String>.from(
                  content['imageStatistic'].whereType<String>());
              debugPrint('✅ Dữ liệu ảnh hợp lệ: $images');
            } else {
              debugPrint(
                  '❌ Dữ liệu ảnh không đúng kiểu: ${content['imageStatistic'].runtimeType}');
            }
          }

          // Xác định loại tin nhắn dựa trên type từ fetchChatHistory
          final messageType = content['type']; // 'question' hoặc 'answer'
          final isUser = messageType == 'question'; // Câu hỏi là từ user

          // Tạo tin nhắn với cấu trúc đầy đủ
          Map<String, dynamic> message = {
            'type': isUser ? 'user' : 'bot',
            'text': content['text'] ?? "",
            'query':
                content['query'] ?? "", // Thêm query để có thể sử dụng nếu cần
            'table': tableData,
            'imageStatistic': images,
            'suggestions': suggestions,
            'originalType':
                messageType, // Giữ lại loại gốc để xử lý đặc biệt nếu cần
          };

          _messages.insert(0, message);
        }
      });

      // Cuộn xuống cuối cùng sau khi danh sách tin nhắn cập nhật
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      historyidProvider.setChatbotHistoryId(newHistoryId);
    } catch (e, stackTrace) {
      debugPrint("❌ Error in fetchAndUpdateChatHistory: $e");
      debugPrint("🛑 StackTrace: $stackTrace");

      // Hiển thị thông báo lỗi cho người dùng nếu cần
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải lịch sử chat: ${e.toString()}')),
        );
      }
    }
  }

  List<InlineSpan> _parseMessage(String message, BuildContext context) {
    List<InlineSpan> spans = [];

    // Updated regex patterns
    RegExp regexBold = RegExp(r'\*\*(.*?)\*\*'); // **bold**
    RegExp regexItalic = RegExp(r'##(.*?)##'); // ##italic##
    RegExp regexBoldItalicLine =
        RegExp(r'^\s*###\s*(.*?)\s*$', multiLine: true);

    RegExp regexNumberedListItem =
        RegExp(r'^###\s+\d+\.\s+(.*)$', multiLine: true); // ### 1. text
    RegExp regexImage = RegExp(r'!\[(.*?)\]\((.*?)\)'); // images ![alt](url)
    RegExp regexLink = RegExp(
        r'(\*\*|##)?\[(.*?)\]\((.*?)(?:\s+"(.*?)")?\)(\*\*|##)?'); // links
    RegExp regexImageInLink =
        RegExp(r'\[(!\[.*?\]\(.*?\))](\(.*?\))'); // images in links

    int lastIndex = 0;

    while (lastIndex < message.length) {
      List<RegExpMatch?> matches = [
        regexImageInLink.firstMatch(message.substring(lastIndex)),
        regexImage.firstMatch(message.substring(lastIndex)),
        regexLink.firstMatch(message.substring(lastIndex)),
        regexNumberedListItem.firstMatch(message.substring(lastIndex)),
        regexBoldItalicLine.firstMatch(message.substring(lastIndex)),
        regexBold.firstMatch(message.substring(lastIndex)),
        regexItalic.firstMatch(message.substring(lastIndex)),
      ].where((match) => match != null).toList();

      if (matches.isEmpty) {
        spans.add(TextSpan(
          text: message.substring(lastIndex),
          style: GoogleFonts.inter(color: Colors.black),
        ));
        break;
      }

      matches.sort((a, b) => a!.start.compareTo(b!.start));
      var match = matches.first!;

      if (match.start > 0) {
        spans.add(TextSpan(
          text: message.substring(lastIndex, lastIndex + match.start),
          style: GoogleFonts.inter(color: Colors.black),
        ));
      }

      if (match.pattern == regexImageInLink) {
        // Handle image in link
        String imageMarkdown = match.group(1)!;
        String linkUrl =
            match.group(2)!.substring(1, match.group(2)!.length - 1);

        var imageMatch = regexImage.firstMatch(imageMarkdown);
        if (imageMatch != null) {
          String altText = imageMatch.group(1)!;
          String imageUrl = imageMatch.group(2)!;

          bool isImageUrl =
              RegExp(r'\.(jpg|jpeg|png|gif|webp)$', caseSensitive: false)
                      .hasMatch(imageUrl) ||
                  imageUrl.contains('bizweb.dktcdn.net') ||
                  imageUrl.startsWith('http');

          if (isImageUrl) {
            spans.add(WidgetSpan(
                child: _buildImageWithLink(context, imageUrl, linkUrl)));
          } else {
            spans.add(TextSpan(
                text: match[0], style: GoogleFonts.inter(color: Colors.black)));
          }
        }
      } else if (match.pattern == regexImage) {
        String altText = match.group(1)!;
        String imageUrl = match.group(2)!;
        spans.add(WidgetSpan(child: _buildImage(context, imageUrl)));
      } else if (match.pattern == regexLink) {
        String linkText = match.group(2)!;
        String linkUrl = match.group(3)!;
        bool isBold = match.group(1) == '**' || match.group(5) == '**';
        bool isItalic = match.group(1) == '##' || match.group(5) == '##';

        final linkStyle = GoogleFonts.inter(
          color: Colors.blue.shade800, // Màu xanh đậm
          decoration: TextDecoration.underline,
          decorationColor: Colors.blue.shade800, // Màu gạch chân
          decorationThickness: 1.5, // Độ dày gạch chân
          fontWeight: isBold ? FontWeight.bold : null,
          fontStyle: isItalic ? FontStyle.italic : null,
        );

        spans.add(TextSpan(
          text: linkText,
          style:
              GoogleFonts.inter().merge(linkStyle), // Kết hợp với GoogleFonts
          recognizer: TapGestureRecognizer()..onTap = () => _launchUrl(linkUrl),
        ));
      } else if (match.pattern == regexNumberedListItem) {
        // Handle ### 1. Text format
        String itemText = match.group(1)!;
        spans.add(TextSpan(
          text: match.group(0), // The entire matched string (### 1. Text)
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 16,
            color: Colors.black,
          ),
        ));
      } else if (match.pattern == regexBoldItalicLine) {
        String boldItalicText = match.group(1)!;
        spans.add(TextSpan(
          text: boldItalicText,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 16,
            color: Colors.black,
          ),
        ));
      } else if (match.pattern == regexBold) {
        spans.add(TextSpan(
          text: match.group(1)!,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.black,
          ),
        ));
      } else if (match.pattern == regexItalic) {
        spans.add(TextSpan(
          text: match.group(1)!,
          style: GoogleFonts.inter(
            fontStyle: FontStyle.italic,
            fontSize: 16,
            color: Colors.black,
          ),
        ));
      }

      lastIndex = lastIndex + match.end;
    }

    return spans;
  }

// Helper methods
  Widget _buildImage(BuildContext context, String imageUrl) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, imageUrl),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          return loadingProgress == null
              ? child
              : const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Text('Không thể tải ảnh');
        },
      ),
    );
  }

  Widget _buildImageWithLink(
      BuildContext context, String imageUrl, String linkUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: () => _launchUrl(linkUrl),
        child: Image.network(
          imageUrl,
          width: MediaQuery.of(context).size.width * 0.8,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            return loadingProgress == null
                ? child
                : const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Text('Không thể tải ảnh');
          },
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              PhotoView(
                imageProvider: NetworkImage(imageUrl),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.0,
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  final ScrollController _scrollController = ScrollController();
  final platformMapping = {
    'playground': 'Trải Nghiệm Thử',
    'zalo': 'Zalo', // Ví dụ thêm
    'facebook': 'Facebook',
  };
  @override
  Widget build(BuildContext context) {
    final selectColors = Provider.of<Providercolor>(context).selectedColor;
    final platform = Provider.of<PlatformProvider>(context).platform;

    final textChatBot = GoogleFonts.inter(
      fontSize: 14,
      color: Colors.black,
    );
    final textChatbotTable = GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue);

    _messages = Provider.of<ChatProvider>(context).messages();
    return Container(
      constraints: const BoxConstraints.expand(),
      color: Colors.white,
      child: Column(
        children: [
          Visibility(
            visible: platform.isNotEmpty,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 30,
                  margin: EdgeInsets.all(10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.withOpacity(0.4)),

                  child: Center(
                    child: Text(
                      platformMapping[platform] ?? platform,
                      style:
                          GoogleFonts.inter(fontSize: 11, color: Colors.black),
                    ),
                  ), // Đặt Text ở giữa nếu cần
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              reverse: false,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];

                final isUser = message['type'] ==
                    'user'; // Xác định user hay bot từ dữ liệu

                return Row(
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          Visibility(
                            visible: (message['text']?.isNotEmpty ?? false) ||
                                (message['imageStatistic'] != null &&
                                    (message['imageStatistic'] as List<dynamic>)
                                        .isNotEmpty),
                            child: isUser
                                ? ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.8,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      margin: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        color: selectColors == Colors.white
                                            ? (isUser
                                                ? const Color(
                                                    0xffed5113) // Orange when white and isUser
                                                : selectColors) // White when white and not isUser
                                            : (selectColors ==
                                                    const Color(0xFF284973)
                                                ? (isUser
                                                    ? selectColors
                                                    : null) // Blue or orange
                                                : (selectColors ==
                                                        const Color(0xff48433d)
                                                    ? (isUser
                                                        ? const Color(
                                                            0xff48433d)
                                                        : null) // Blue or black
                                                    : selectColors)), // Fallback to selectColors
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.zero,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: _parseMessage(
                                                      message['text'] ?? '',
                                                      context)
                                                  .map((span) {
                                                if (span is TextSpan) {
                                                  return TextSpan(
                                                    text: span.text,
                                                    style: span.style?.copyWith(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .white, // Chữ trắng cho user
                                                        height: 1.5),
                                                    recognizer: span.recognizer,
                                                  );
                                                } else {
                                                  return span;
                                                }
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                : ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.9),
                                    child: Container(
                                        padding: const EdgeInsets.only(
                                            right: 10, top: 10, bottom: 10),
                                        decoration: BoxDecoration(
                                          color: selectColors == Colors.white
                                              ? (isUser
                                                  ? const Color(
                                                      0xffed5113) // Orange when white and isUser
                                                  : selectColors) // White when white and not isUser
                                              : (selectColors ==
                                                      const Color(0xFF284973)
                                                  ? (isUser
                                                      ? selectColors
                                                      : null) // Blue or orange
                                                  : (selectColors ==
                                                          const Color(
                                                              0xff48433d)
                                                      ? (isUser
                                                          ? const Color(
                                                              0xff48433d)
                                                          : null) // Blue or black
                                                      : selectColors)), // Fallback to selectColors
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.zero,
                                            bottomRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            if (message['text']?.isNotEmpty ??
                                                false)
                                              RichText(
                                                text: TextSpan(
                                                  children: _parseMessage(
                                                          message['text'] ?? '',
                                                          context)
                                                      .map((span) {
                                                    if (span is TextSpan) {
                                                      return TextSpan(
                                                        text: span.text,
                                                        style: span.style
                                                            ?.copyWith(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                          height: 1.5,
                                                        ),
                                                        recognizer:
                                                            span.recognizer,
                                                      );
                                                    }
                                                    return span;
                                                  }).toList(),
                                                ),
                                              ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            if (message['imageStatistic'] !=
                                                    null &&
                                                message['imageStatistic']
                                                    is List<String> &&
                                                (message['imageStatistic']
                                                        as List<String>)
                                                    .isNotEmpty)
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.8,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (message['imageCaption']
                                                            ?.isNotEmpty ??
                                                        false)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 4),
                                                        child: Text(
                                                          message[
                                                              'imageCaption'],
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ),

                                                    // Vertical image list with default sizing
                                                    Column(
                                                      children: (message[
                                                                  'imageStatistic']
                                                              as List<String>)
                                                          .map((imageUrl) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 8),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        Dialog(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  child:
                                                                      PhotoView(
                                                                    imageProvider:
                                                                        NetworkImage(
                                                                            imageUrl),
                                                                    backgroundDecoration:
                                                                        const BoxDecoration(
                                                                            color:
                                                                                Colors.white),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              child:
                                                                  Image.network(
                                                                imageUrl,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.8, // Default width
                                                                // height:
                                                                //     200, // Default height
                                                                fit: BoxFit
                                                                    .cover,
                                                                loadingBuilder:
                                                                    (context,
                                                                        child,
                                                                        loadingProgress) {
                                                                  if (loadingProgress ==
                                                                      null)
                                                                    return child;
                                                                  return SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.8,
                                                                    // height: 200,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        value: loadingProgress.expectedTotalBytes !=
                                                                                null
                                                                            ? loadingProgress.cumulativeBytesLoaded /
                                                                                loadingProgress.expectedTotalBytes!
                                                                            : null,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.8,
                                                                    color: Colors
                                                                            .grey[
                                                                        200],
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .error,
                                                                      size: 40,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        )),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_isLoading) ...[
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.0, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Trợ lý AI đang trả lời...',
                    style: textChatBot,
                  ),
                ],
              ),
            ),
          ],
          Container(
            height: 85,
            padding: const EdgeInsets.only(bottom: 10, left: 10),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      hintStyle: textChatBot,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                ),
                Visibility(
                  visible: !_isLoading,
                  child: IconButton(
                    icon: Icon(
                        _isLoading ? Icons.hourglass_empty : Icons.send_rounded,
                        color: Colors.black),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
