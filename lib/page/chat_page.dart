import 'package:chatbotbnn/model/body_chatbot_answer.dart';
import 'package:chatbotbnn/model/chatbot_config.dart';
import 'package:chatbotbnn/model/history_all_model.dart';
import 'package:chatbotbnn/provider/chat_provider.dart';
import 'package:chatbotbnn/provider/chatbot_provider.dart';
import 'package:chatbotbnn/provider/historyid_provider.dart';
import 'package:chatbotbnn/provider/provider_color.dart';
import 'package:chatbotbnn/service/anwser_number.dart';
import 'package:chatbotbnn/service/chatbot_config_service.dart';
import 'package:chatbotbnn/service/history_all_service.dart';
import 'package:chatbotbnn/service/history_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // print('Cấu hình: $chatbotRequest');

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

          // Kiểm tra và xử lý dữ liệu ảnh
          if (content.containsKey('imageStatistic') &&
              content['imageStatistic'] is List<String>) {
            images = List<String>.from(content['imageStatistic']);
            debugPrint('✅ Dữ liệu ảnh hợp lệ: $images');
          } else {
            debugPrint(
                '❌ Dữ liệu ảnh không đúng kiểu: ${content['imageStatistic'].runtimeType}');
          }

          // Xác định loại tin nhắn (user hay bot) từ dữ liệu lịch sử
          final isUser = content['type'] == 'user';

          // Thêm tin nhắn vào danh sách với cấu trúc phù hợp
          _messages.insert(0, {
            'type': isUser ? 'user' : 'bot', // Phân biệt user và bot
            'text': content['text'] ?? "",
            'table': content['table'] as List<Map<String, dynamic>>?,
            'imageStatistic': images,
          });
        }
      });

      // Cuộn xuống cuối cùng sau khi danh sách tin nhắn cập nhật
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });

      historyidProvider.setChatbotHistoryId(newHistoryId);
    } catch (e, stackTrace) {
      debugPrint("❌ Error in fetchAndUpdateChatHistory: $e");
      debugPrint("🛑 StackTrace: $stackTrace");
    }
  }

  List<InlineSpan> _parseMessage(String message) {
    List<InlineSpan> spans = [];
    RegExp regexBold = RegExp(r'\*\*(.*?)\*\*'); // In đậm
    RegExp regexItalic = RegExp(r'##(.*?)##'); // In nghiêng
    RegExp regexBoldLine = RegExp(r'^\s*###\s*(.*?)\s*$', multiLine: true);
    RegExp regexImage = RegExp(r'!\[(.*?)\]\((.*?)\)'); // Ảnh Markdown
    RegExp regexLink = RegExp(r'\[(.*?)\]\((.*?)\)'); // Link dạng Markdown

    int lastIndex = 0;

    while (lastIndex < message.length) {
      List<RegExpMatch?> matches = [
        regexImage.firstMatch(message.substring(lastIndex)),
        regexLink.firstMatch(message.substring(lastIndex)),
        regexBoldLine.firstMatch(message.substring(lastIndex)),
        regexItalic.firstMatch(message.substring(lastIndex)),
        regexBold.firstMatch(message.substring(lastIndex)),
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

      // Thêm văn bản thường trước phần định dạng
      if (match.start > 0) {
        spans.add(TextSpan(
          text: message.substring(lastIndex, lastIndex + match.start),
          style: GoogleFonts.inter(color: Colors.black),
        ));
      }

      if (match.pattern == regexImage) {
        String linkText =
            match.group(1)!; // Văn bản thay thế (không dùng trong code này)
        String linkUrl = match.group(2)!;

        // Kiểm tra xem có phải link ảnh không
        bool isImageUrl =
            RegExp(r'\.(jpg|jpeg|png|gif|webp)$', caseSensitive: false)
                .hasMatch(linkUrl);

        if (isImageUrl) {
          spans.add(
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: PhotoView(
                            imageProvider: NetworkImage(linkUrl),
                            backgroundDecoration:
                                const BoxDecoration(color: Colors.white),
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered * 2.0,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Image.network(
                    linkUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Không thể tải ảnh');
                    },
                  ),
                ),
              ),
            ),
          );
        } else {
          spans.add(TextSpan(
            text: match[0],
            style: GoogleFonts.inter(color: Colors.black),
          ));
        }
      } else if (match.pattern == regexLink) {
        String linkText = match.group(1)!;
        String linkUrl = match.group(2)!;

        spans.add(TextSpan(
          text: linkText,
          style: GoogleFonts.inter(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              String url =
                  linkUrl.startsWith('http') ? linkUrl : 'https://$linkUrl';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication);
              }
            },
        ));
      } else if (match.pattern == regexBoldLine) {
        spans.add(TextSpan(
          text: "\n${match.group(1)!}",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
      } else if (match.pattern == regexBold) {
        spans.add(TextSpan(
          text: match.group(1)!,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.black,
          ),
        ));
      }

      lastIndex = lastIndex + match.end; // Cập nhật chỉ số chính xác
    }

    return spans;
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final selectColors = Provider.of<Providercolor>(context).selectedColor;
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
                // final String? imageUrl = message['image'];
                // List<Map<String, dynamic>>? table = message['table'];
                // List<String> columns = [];
                // if (table != null && table.isNotEmpty) {
                //   columns = table.first.keys.toList();
                // }

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
                                ? Container(
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
                                                      ? const Color(0xff48433d)
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
                                                    message['text'] ?? '')
                                                .map((span) {
                                              if (span is TextSpan) {
                                                return TextSpan(
                                                  text: span.text,
                                                  style: span.style?.copyWith(
                                                    fontSize: 13,
                                                    color: Colors
                                                        .white, // Chữ trắng cho user
                                                  ),
                                                  recognizer: span.recognizer,
                                                );
                                              } else {
                                                return span;
                                              }
                                            }).toList(),
                                          ),
                                        ),
                                        if (message['imageStatistic'] != null &&
                                            message['imageStatistic']
                                                is List<String> &&
                                            (message['imageStatistic']
                                                    as List<String>)
                                                .isNotEmpty)
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: (message['imageStatistic']
                                                    as List<String>)
                                                .map((imageUrl) {
                                              return GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        Dialog(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.7,
                                                          child: PhotoView(
                                                            imageProvider:
                                                                NetworkImage(
                                                                    imageUrl),
                                                            backgroundDecoration:
                                                                const BoxDecoration(
                                                                    color: Colors
                                                                        .white),
                                                            minScale:
                                                                PhotoViewComputedScale
                                                                    .contained,
                                                            maxScale:
                                                                PhotoViewComputedScale
                                                                        .covered *
                                                                    2.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return const SizedBox(
                                                      child: Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.error,
                                                        size: 100,
                                                        color: Colors.red);
                                                  },
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                      ],
                                    ),
                                  )
                                : Container(
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
                                                      const Color(0xff48433d)
                                                  ? (isUser
                                                      ? const Color(0xff48433d)
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
                                        RichText(
                                          text: TextSpan(
                                            children: _parseMessage(
                                                    message['text'] ?? '')
                                                .map((span) {
                                              if (span is TextSpan) {
                                                return TextSpan(
                                                  text: span.text,
                                                  style: span.style?.copyWith(
                                                    fontSize: 13,
                                                    color: Colors
                                                        .black, // Chữ đen cho bot
                                                  ),
                                                  recognizer: span.recognizer,
                                                );
                                              } else {
                                                return span;
                                              }
                                            }).toList(),
                                          ),
                                        ),
                                        if (message['imageStatistic'] != null &&
                                            message['imageStatistic']
                                                is List<String> &&
                                            (message['imageStatistic']
                                                    as List<String>)
                                                .isNotEmpty)
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: (message['imageStatistic']
                                                    as List<String>)
                                                .map((imageUrl) {
                                              return GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        Dialog(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.7,
                                                          child: PhotoView(
                                                            imageProvider:
                                                                NetworkImage(
                                                                    imageUrl),
                                                            backgroundDecoration:
                                                                const BoxDecoration(
                                                                    color: Colors
                                                                        .white),
                                                            minScale:
                                                                PhotoViewComputedScale
                                                                    .contained,
                                                            maxScale:
                                                                PhotoViewComputedScale
                                                                        .covered *
                                                                    2.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return const SizedBox(
                                                      width: 100,
                                                      height: 100,
                                                      child: Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.error,
                                                        size: 100,
                                                        color: Colors.red);
                                                  },
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                      ],
                                    ),
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
            padding: const EdgeInsets.all(10),
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
