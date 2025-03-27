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
    print('Cấu hình: $chatbotRequest');

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
          _messages[0]['imageStatistic'] = images;
        } else {
          _messages.insert(0, {
            'type': 'bot',
            'text': '',
            'table': table,
            // 'imageStatistic': images,
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
  // // 📌 Gọi API
  // AnswerModelPq? responsepq = await fetchApiResponsePq(chatbotRequest);

  // if (responsepq != null && responsepq.data != null) {
  //   DataAnswer? responseData = responsepq.data;

  //   // 📌 Lấy tin nhắn từ chatbot
  //   String botResponse =
  //       responseData?.message ?? "Chatbot không có câu trả lời.";

  //   // 📌 Tìm ảnh trong nội dung Markdown
  //   RegExp markdownImageRegex = RegExp(r'!\[.*?\]\((.*?)\)');
  //   List<String> imageUrls = responseData?.images ?? [];

  //   // 📌 Trích xuất ảnh từ Markdown
  //   for (RegExpMatch match in markdownImageRegex.allMatches(botResponse)) {
  //     if (match.group(1) != null) {
  //       imageUrls.add(match.group(1)!);
  //     }
  //   }

  //   setState(() {
  //     _messages.insert(0, {
  //       'type': 'bot',
  //       'text': botResponse,
  //       'images': imageUrls,
  //     });
  //   });
  // } else {
  //   setState(() {
  //     _messages.insert(
  //         0, {'type': 'bot', 'text': "Chatbot không thể trả lời lúc này."});
  //   });
  // }

  // setState(() {
  //   _isLoading = false;
  // });

  Future<void> fetchAndUpdateChatHistory() async {
    if (!mounted) return;

    final historyidProvider =
        Provider.of<HistoryidProvider>(context, listen: false);
    final newHistoryId = historyidProvider.chatbotHistoryId;

    // Nếu không có lịch sử chat, không cần fetch
    if (newHistoryId.isEmpty) {
      debugPrint("⚠️ No chatbot history ID available.");
      return;
    }

    // Kiểm tra nếu không có thay đổi ID, tránh load lại không cần thiết
    if (_messages.isNotEmpty &&
        historyidProvider.previousHistoryId == newHistoryId) {
      debugPrint("🔄 No changes in history ID, skipping fetch.");
      return;
    }

    try {
      debugPrint("📡 Fetching chat history for ID: $newHistoryId");

      // Lấy dữ liệu tin nhắn từ API
      List<Map<String, dynamic>> contents =
          await fetchChatHistory(newHistoryId);

      if (!mounted) return;

      setState(() {
        _messages.clear(); // Xóa tin nhắn cũ trước khi cập nhật

        for (var content in contents) {
          List<dynamic> images = [];

          // Kiểm tra và xử lý danh sách hình ảnh từ `imageStatistic`
          if (content.containsKey('imageStatistic')) {
            var imageData = content['imageStatistic'];

            if (imageData is List<String>) {
              images = imageData;
              debugPrint('✅ Dữ liệu ảnh hợp lệ: $images');
            } else {
              debugPrint(
                  '❌ Dữ liệu ảnh không đúng kiểu: ${imageData.runtimeType}');
            }
          }

          // Chèn tin nhắn vào danh sách `_messages`
          _messages.insert(0, {
            'type': 'bot',
            'text': content['text'] ?? "",
            'table': content['table'] as List<Map<String, dynamic>>?,
            'imageStatistic': images,
          });
          // Cuộn xuống cuối cùng sau khi danh sách tin nhắn cập nhật
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }
      });

      // Cập nhật lại `previousHistoryId` sau khi tải xong
      historyidProvider.setChatbotHistoryId(newHistoryId);
    } catch (e, stackTrace) {
      debugPrint("❌ Error in fetchAndUpdateChatHistory: $e");
      debugPrint("🛑 StackTrace: $stackTrace");
    }
  }

  void loadChatHistoryId(BuildContext context, String chatbotCode) async {
    debugPrint("🔍 Starting loadChatHistoryId...");

    try {
      HistoryAllModel historyData =
          await fetchChatHistoryAll(chatbotCode, null, null);
      debugPrint("📥 Fetched history data: ${historyData.toJson()}");

      int? historyId = int.tryParse(
          Provider.of<HistoryidProvider>(context, listen: false)
              .chatbotHistoryId);

      if (historyId != null && historyId > 0) {
        Provider.of<HistoryidProvider>(context, listen: false)
            .setChatbotHistoryId(historyId.toString());
      } else {
        debugPrint("⚠ No valid history data found in Provider.");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Error in loadChatHistoryId: $e");
      debugPrint("🛑 StackTrace: $stackTrace");
    }
  }

  List<TextSpan> _parseMessage(String message) {
    List<TextSpan> spans = [];
    RegExp regexBold = RegExp(r'\*\*(.*?)\*\*'); // In đậm
    RegExp regexItalic = RegExp(r'##(.*?)##'); // In nghiêng
    RegExp regexBoldLine = RegExp(r'^\s*###\s*(.*?)\s*$', multiLine: true);

    RegExp regexLink = RegExp(r'\[(.*?)\]\((.*?)\)'); // Link dạng Markdown

    int lastIndex = 0;

    while (lastIndex < message.length) {
      List<RegExpMatch?> matches = [
        regexLink.firstMatch(message.substring(lastIndex)),
        regexBoldLine.firstMatch(message.substring(lastIndex)),
        regexItalic.firstMatch(message.substring(lastIndex)),
        regexBold.firstMatch(message.substring(lastIndex)),
      ].where((match) => match != null).toList();

      if (matches.isEmpty) {
        spans.add(TextSpan(text: message.substring(lastIndex)));
        break;
      }

      matches.sort((a, b) => a!.start.compareTo(b!.start));
      var match = matches.first!;

      // Thêm văn bản thường trước phần định dạng
      if (match.start > 0) {
        spans.add(TextSpan(
            text: message.substring(lastIndex, lastIndex + match.start)));
      }

      // Xử lý từng loại định dạng
      if (match.pattern == regexLink) {
        String linkText = match.group(1)!;
        String linkUrl = match.group(2)!;

        spans.add(TextSpan(
          text: linkText,
          style: GoogleFonts.inter(
              color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunchUrl(Uri.parse(linkUrl))) {
                await launchUrl(Uri.parse(linkUrl),
                    mode: LaunchMode.externalApplication);
              }
            },
        ));
      } else if (match.pattern == regexBoldLine) {
        spans.add(TextSpan(
          text: "\n${match.group(1)!}",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ));
      } else if (match.pattern == regexItalic) {
        spans.add(TextSpan(
          text: match.group(1)!,
          style: GoogleFonts.inter(fontStyle: FontStyle.italic, fontSize: 16),
        ));
      } else if (match.pattern == regexBold) {
        spans.add(TextSpan(
          text: match.group(1)!,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
        ));
      }

      lastIndex += match.end;
    }

    return spans;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
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
    // _messages = _chatProvider!.messages();
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

                final isUser = message['type'] == 'user';
                String extractImageUrl(String markdownText) {
                  RegExp exp = RegExp(r'!\[.*?\]\((.*?)\)');
                  Match? match = exp.firstMatch(markdownText);
                  return match != null
                      ? match.group(1)!
                      : markdownText; // Trả về URL ảnh nếu có
                }

                List<String> imageUrls = message['images'] ?? [];

// 📌 Trích xuất URL ảnh trước khi hiển thị
                List<String> validImageUrls =
                    imageUrls.map((e) => extractImageUrl(e)).toList();

                // final String? imageUrl = message['image'];
                List<Map<String, dynamic>>? table = message['table'];
                List<String> columns = [];
                if (table != null && table.isNotEmpty) {
                  columns = table.first.keys.toList();
                }

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment
                          .centerLeft, // Canh phải cho user, trái cho bot

                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Column(
                          children: [
                            Visibility(
                              visible: message['text']?.isNotEmpty ?? false,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      isUser ? selectColors : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(10),
                                    topRight: const Radius.circular(10),
                                    bottomLeft: isUser
                                        ? const Radius.circular(10)
                                        : Radius.zero,
                                    bottomRight: isUser
                                        ? Radius.zero
                                        : const Radius.circular(10),
                                  ),
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    // children: _parseMessage(message['text']!),
                                    children:
                                        _parseMessage(message['text'] ?? ''),
                                  ),
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color:
                                          isUser ? Colors.black : Colors.black),
                                ),
                              ),
                            ),
                            // 📌 Hiển thị danh sách ảnh nếu có
                            // if (validImageUrls.isNotEmpty)
                            //   Wrap(
                            //     spacing: 8.0, // Khoảng cách giữa các ảnh
                            //     runSpacing: 8.0,
                            //     children: validImageUrls.map((imageUrl) {
                            //       return GestureDetector(
                            //         onTap: () {
                            //           // // Mở ảnh toàn màn hình khi nhấn vào
                            //           // Navigator.push(
                            //           //   context,
                            //           //   MaterialPageRoute(
                            //           //     builder: (context) => FullScreenImage(imageUrl: imageUrl),
                            //           //   ),
                            //           // );
                            //         },
                            //         child: ClipRRect(
                            //           borderRadius: BorderRadius.circular(10),
                            //           child: Image.network(
                            //             imageUrl,
                            //             width: 100,
                            //             height: 100,
                            //             fit: BoxFit.cover,
                            //           ),
                            //         ),
                            //       );
                            //     }).toList(),
                            //   ),

                            // 🖼 Kiểm tra nếu có ảnh thì hiển thị ảnh
                            Builder(
                              builder: (context) {
                                final regex = RegExp(
                                    r'!\[.*?\]\((https?://[^\)]+\.(png|jpg|jpeg|gif|webp))\)');

                                final match =
                                    regex.firstMatch(message['text'] ?? '');

                                if (match != null) {
                                  String imageUrl =
                                      match.group(1)!; // Lấy URL ảnh

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }
                                return SizedBox.shrink(); // Không có ảnh thì ẩn
                              },
                            ),

                            // if (!isUser)
                            //   Row(
                            //     children: [
                            //       Row(
                            //         children: [
                            //           GestureDetector(
                            //             onTap: () {
                            //               Clipboard.setData(ClipboardData(
                            //                   text: message['text'] ?? ''));
                            //               ScaffoldMessenger.of(context)
                            //                   .showSnackBar(
                            //                 const SnackBar(
                            //                     content: Text(
                            //                         'Đã sao chép vào clipboard!')),
                            //               );
                            //             },
                            //             child: const Row(
                            //               mainAxisSize: MainAxisSize.min,
                            //               children: [
                            //                 Icon(Icons.copy,
                            //                     size: 18, color: Colors.grey),
                            //                 SizedBox(width: 4),
                            //               ],
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            if (table != null &&
                                table is List &&
                                (table as List<Map<String, dynamic>>)
                                    .isNotEmpty)
                              SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: [
                                      DataColumn(
                                        label: Text(
                                          "STT",
                                          style: textChatbotTable,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      ...columns.map((col) => DataColumn(
                                            label: Text(
                                              col,
                                              style: textChatbotTable,
                                              textAlign: TextAlign.center,
                                            ),
                                          ))
                                    ],
                                    rows: table!
                                        .asMap()
                                        .entries
                                        .map<DataRow>((entry) {
                                      int index =
                                          entry.key + 1; // Đánh số thứ tự
                                      Map<String, dynamic> row = entry.value;
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            SizedBox(
                                              width: 40,
                                              child: Center(
                                                child: Text(
                                                  index.toString(),
                                                  style: textChatBot,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                          ...columns.map((col) {
                                            var value = row[col];
                                            String displayValue;

                                            // Kiểm tra nếu giá trị là số thì làm tròn đến 2 chữ số thập phân
                                            if (value is double) {
                                              displayValue =
                                                  value.toStringAsFixed(2);
                                            } else {
                                              displayValue = value.toString();
                                            }

                                            return DataCell(
                                              Center(
                                                child: Text(
                                                  displayValue,
                                                  style: textChatBot,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            if (message['imageStatistic'] != null &&
                                message['imageStatistic'] is List<String> &&
                                message['imageStatistic'].isNotEmpty)
                              ...(message['imageStatistic'] as List<String>)
                                  .map<Widget>((imageUrl) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.7,
                                                child: PhotoView(
                                                  imageProvider: NetworkImage(
                                                      imageUrl), // Sử dụng imageUrl thay vì image.path
                                                  backgroundDecoration:
                                                      const BoxDecoration(
                                                          color: Colors.white),
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
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isUser
                                              ? selectColors
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              width: 2,
                                              color:
                                                  Colors.grey.withOpacity(0.3)),
                                        ),
                                        child: Image.network(
                                            imageUrl), // Sử dụng imageUrl thay vì image.path!
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
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
          if (_suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _suggestions.map((suggestion) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          _controller.text = suggestion; // Đưa gợi ý vào ô nhập
                        },
                        child: Text(suggestion),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
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
                const SizedBox(width: 10),
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
