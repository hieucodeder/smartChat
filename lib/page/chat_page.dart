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

//
  // List<InlineSpan> _parseMessage(String message, BuildContext context) {
  //   List<InlineSpan> spans = [];

  //   // Cập nhật regex để bắt đúng format từ API
  //   RegExp regexBold = RegExp(r'\*\*(.*?)\*\*');
  //   RegExp regexItalic = RegExp(r'\*(.*?)\*');
  //   RegExp regexBoldItalic = RegExp(r'\*\*\*(.*?)\*\*\*');
  //   RegExp regexListItem = RegExp(r'^\s*(\d+\.|\*)\s+(.*)', multiLine: true);
  //   RegExp regexImage = RegExp(r'!\[(.*?)\]\((.*?)\)');
  //   RegExp regexLink = RegExp(r'\[(.*?)\]\((.*?)\)');

  //   // Thêm regex cho các trường hợp đặc biệt từ API
  //   RegExp regexApiBold = RegExp(r'\s\*\*(.*?)\*\*\s');RegExp(r'^###\s+(.+)$', multiLine: true);
  //   RegExp regexApiItalic = RegExp(r'\s\*(.*?)\*\s');

  //   int lastIndex = 0;

  //   // Hàm helper để thêm text thường
  //   void addNormalText(int start, int end) {
  //     if (start < end) {
  //       spans.add(TextSpan(
  //         text: message.substring(start, end),
  //         style: GoogleFonts.inter(color: Colors.black),
  //       ));
  //     }
  //   }

  //   while (lastIndex < message.length) {
  //     // Ưu tiên các pattern phức tạp trước
  //     final imageMatch = regexImage.firstMatch(message.substring(lastIndex));
  //     final linkMatch = regexLink.firstMatch(message.substring(lastIndex));
  //     final boldItalicMatch =
  //         regexBoldItalic.firstMatch(message.substring(lastIndex));
  //     final boldMatch = regexBold.firstMatch(message.substring(lastIndex));
  //     final italicMatch = regexItalic.firstMatch(message.substring(lastIndex));
  //     final listItemMatch =
  //         regexListItem.firstMatch(message.substring(lastIndex));
  //     final apiBoldMatch =
  //         regexApiBold.firstMatch(message.substring(lastIndex));
  //     final apiItalicMatch =
  //         regexApiItalic.firstMatch(message.substring(lastIndex));

  //     // Xác định match gần nhất
  //     RegExpMatch? firstMatch;
  //     int firstPos = message.length;

  //     void checkMatch(RegExpMatch? match) {
  //       if (match != null && match.start < firstPos) {
  //         firstMatch = match;
  //         firstPos = match.start;
  //       }
  //     }

  //     checkMatch(imageMatch);
  //     checkMatch(linkMatch);
  //     checkMatch(boldItalicMatch);
  //     checkMatch(boldMatch);
  //     checkMatch(italicMatch);
  //     checkMatch(listItemMatch);
  //     checkMatch(apiBoldMatch);
  //     checkMatch(apiItalicMatch);

  //     if (firstMatch == null) {
  //       // Không còn pattern nào, thêm phần còn lại
  //       addNormalText(lastIndex, message.length);
  //       break;
  //     }

  //     // Thêm text bình thường trước match
  //     addNormalText(lastIndex, lastIndex + firstMatch!.start);

  //     // Xử lý từng loại match
  //     if (firstMatch!.pattern == regexImage) {
  //       // Xử lý ảnh (giữ nguyên như code cũ)
  //       String altText = firstMatch!.group(1)!;
  //       String imageUrl = firstMatch!.group(2)!;

  //       spans.add(
  //         WidgetSpan(
  //           child: Image.network(
  //             imageUrl,
  //             width: double.infinity,
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //       );
  //     } else if (firstMatch!.pattern == regexLink) {
  //       // Xử lý link
  //       String text = firstMatch!.group(1)!;
  //       String url = firstMatch!.group(2)!;

  //       spans.add(TextSpan(
  //         text: text,
  //         style: GoogleFonts.inter(
  //           color: Colors.blue,
  //           decoration: TextDecoration.underline,
  //         ),
  //         recognizer: TapGestureRecognizer()
  //           ..onTap = () async {
  //             if (await canLaunchUrl(Uri.parse(url))) {
  //               await launchUrl(Uri.parse(url));
  //             }
  //           },
  //       ));
  //     } else if (firstMatch!.pattern == regexBoldItalic ||
  //         firstMatch!.pattern == regexApiBold) {
  //       // Xử lý in đậm
  //       String boldText = firstMatch!.group(1)!;
  //       spans.add(TextSpan(
  //         text: boldText,
  //         style: GoogleFonts.inter(
  //           fontWeight: FontWeight.bold,
  //           color: Colors.black,
  //         ),
  //       ));
  //     } else if (firstMatch!.pattern == regexItalic ||
  //         firstMatch!.pattern == regexApiItalic) {
  //       // Xử lý in nghiêng
  //       String italicText = firstMatch!.group(1)!;
  //       spans.add(TextSpan(
  //         text: italicText,
  //         style: GoogleFonts.inter(
  //           fontStyle: FontStyle.italic,
  //           color: Colors.black,
  //         ),
  //       ));
  //     } else if (firstMatch!.pattern == regexListItem) {
  //       // Xử lý danh sách
  //       String listText = firstMatch!.group(2)!;
  //       spans.add(WidgetSpan(
  //         child: Padding(
  //           padding: const EdgeInsets.only(left: 8.0),
  //           child: Text(
  //             '• $listText',
  //             style: GoogleFonts.inter(color: Colors.black),
  //           ),
  //         ),
  //       ));
  //     }

  //     lastIndex += firstMatch!.end;
  //   }

  //   return spans;
  // }
  List<InlineSpan> _parseMessage(String message, BuildContext context) {
    List<InlineSpan> spans = [];
    RegExp regexBold = RegExp(r'\*\*(.*?)\*\*'); // In đậm
    RegExp regexItalic = RegExp(r'##(.*?)##'); // In nghiêng
    RegExp regexBoldItalicLine = RegExp(r'^\s*###\s*(.*?)\s*$',
        multiLine: true); // Đậm + nghiêng với ### ở đầu dòng
    RegExp regexBoldItalic =
        RegExp(r'\*\*##(.*?)##\*\*|##\*\*(.*?)\*\*##'); // Vừa đậm vừa nghiêng
    RegExp regexImage = RegExp(r'!\[(.*?)\]\((.*?)\)'); // Ảnh Markdown
    RegExp regexLink = RegExp(
        r'(\*\*|##)?\[(.*?)\]\((.*?)(?:\s+"(.*?)")?\)(\*\*|##)?'); // link ảnh nhấn
    RegExp regexImageInLink =
        RegExp(r'\[(!\[.*?\]\(.*?\))](\(.*?\))'); // Nhấn link trong ảnh

    int lastIndex = 0;

    while (lastIndex < message.length) {
      List<RegExpMatch?> matches = [
        regexImageInLink.firstMatch(message.substring(lastIndex)),
        regexImage.firstMatch(message.substring(lastIndex)),
        regexLink.firstMatch(message.substring(lastIndex)),
        regexBoldItalic.firstMatch(message.substring(lastIndex)),
        regexBoldItalicLine.firstMatch(message.substring(lastIndex)),
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

      if (match.start > 0) {
        spans.add(TextSpan(
          text: message.substring(lastIndex, lastIndex + match.start),
          style: GoogleFonts.inter(color: Colors.black),
        ));
      }

      if (match.pattern == regexImageInLink) {
        // Xử lý trường hợp ảnh nằm trong link
        String imageMarkdown = match.group(1)!;
        String linkUrl = match
            .group(2)!
            .substring(1, match.group(2)!.length - 1); // Bỏ dấu ngoặc đơn

        // Trích xuất thông tin ảnh từ imageMarkdown
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
            spans.add(
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: GestureDetector(
                    onTap: () async {
                      String url = linkUrl.startsWith('http')
                          ? linkUrl
                          : 'https://$linkUrl';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Image.network(
                      imageUrl,
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
        }
      } else if (match.pattern == regexImage) {
        String altText = match.group(1)!;
        String linkUrl = match.group(2)!;

        bool isImageUrl =
            RegExp(r'\.(jpg|jpeg|png|gif|webp)$', caseSensitive: false)
                    .hasMatch(linkUrl) ||
                linkUrl.contains('bizweb.dktcdn.net') ||
                linkUrl.startsWith('http');

        if (isImageUrl) {
          spans.add(
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => Dialog(
                        insetPadding: EdgeInsets.zero,
                        backgroundColor: Colors.black,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Stack(
                            children: [
                              PhotoView(
                                imageProvider: NetworkImage(linkUrl),
                                backgroundDecoration: const BoxDecoration(
                                  color: Colors.black,
                                ),
                                minScale: PhotoViewComputedScale.contained,
                                maxScale: PhotoViewComputedScale.covered * 2.0,
                                loadingBuilder: (context, event) =>
                                    const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Text(
                                    'Không thể tải ảnh',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 40,
                                right: 20,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
        String linkText = match.group(2)!; // Text trong []
        String linkUrl = match.group(3)!; // URL trong ()
        String? title = match.group(4); // Tiêu đề (nếu có)
        bool isBold =
            match.group(1) == '**' || match.group(5) == '**'; // Kiểm tra in đậm
        bool isItalic = match.group(1) == '##' ||
            match.group(5) == '##'; // Kiểm tra in nghiêng

        spans.add(TextSpan(
          text: linkText,
          style: GoogleFonts.inter(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            fontWeight: isBold ? FontWeight.bold : null,
            fontStyle: isItalic ? FontStyle.italic : null,
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
      } else if (match.pattern == regexBoldItalic) {
        // Xử lý trường hợp vừa in đậm vừa in nghiêng
        String boldItalicText = match.group(1) ?? match.group(2)!;
        spans.add(TextSpan(
          text: boldItalicText,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 16,
            color: Colors.black,
          ),
        ));
      } else if (match.pattern == regexBoldItalicLine) {
        String boldItalicText = match.group(1)!;
        List<InlineSpan> nestedSpans = _parseMessage(boldItalicText, context);
        spans.add(TextSpan(
          children: nestedSpans,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold, // Đậm
            fontStyle: FontStyle.italic, // Nghiêng
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

      lastIndex = lastIndex + match.end;
    }

    return spans;
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
                                                        fontSize: 13,
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
                                          if (message['imageStatistic'] !=
                                                  null &&
                                              message['imageStatistic']
                                                  is List<String> &&
                                              (message['imageStatistic']
                                                      as List<String>)
                                                  .isNotEmpty)
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children:
                                                  (message['imageStatistic']
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
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return const SizedBox(
                                                        child: Center(
                                                            child:
                                                                CircularProgressIndicator()),
                                                      );
                                                    },
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
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
                                                        const Color(0xff48433d)
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
                                                        fontSize: 13,
                                                        color: Colors
                                                            .black, // Chữ đen cho bot
                                                        height: 1.5),
                                                    recognizer: span.recognizer,
                                                  );
                                                } else {
                                                  return span;
                                                }
                                              }).toList(),
                                            ),
                                          ),
                                          if (message['imageStatistic'] !=
                                                  null &&
                                              message['imageStatistic']
                                                  is List<String> &&
                                              (message['imageStatistic']
                                                      as List<String>)
                                                  .isNotEmpty)
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children:
                                                  (message['imageStatistic']
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
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return const SizedBox(
                                                        width: 100,
                                                        height: 100,
                                                        child: Center(
                                                            child:
                                                                CircularProgressIndicator()),
                                                      );
                                                    },
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
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
