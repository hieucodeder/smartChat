class ResponseBotConfig {
  List<Data>? data;

  ResponseBotConfig({this.data});

  ResponseBotConfig.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? chatbotCode;
  dynamic userIndustry;
  String? queryRewrite;
  String? modelRerank;
  String? modelGenerate;
  String? fallbackResponse;
  String? systemPrompt;
  String? query;
  String? releventContext;
  int? topCount;
  double? threadHold;
  String? collectionName;
  int? temperature;
  String? lang;
  String? createdAt;
  String? updatedAt;
  dynamic slots;
  dynamic history;
  dynamic intentqueue;
  String? chatbotName;
  String? promptContent;
  String? customizePrompt;
  String? promptId;
  String? progress;
  String? defaultConfigs;
  String? slotsConfig;

  Data(
      {this.chatbotCode,
      this.userIndustry,
      this.queryRewrite,
      this.modelRerank,
      this.modelGenerate,
      this.fallbackResponse,
      this.systemPrompt,
      this.query,
      this.releventContext,
      this.topCount,
      this.threadHold,
      this.collectionName,
      this.temperature,
      this.lang,
      this.createdAt,
      this.updatedAt,
      this.slots,
      this.history,
      this.intentqueue,
      this.chatbotName,
      this.promptContent,
      this.customizePrompt,
      this.promptId,
      this.progress,
      this.defaultConfigs,
      this.slotsConfig});

  Data.fromJson(Map<String, dynamic> json) {
    chatbotCode = json['chatbot_code'];
    userIndustry = json['user_industry'];
    queryRewrite = json['query_rewrite'];
    modelRerank = json['model_rerank'];
    modelGenerate = json['model_generate'];
    fallbackResponse = json['fallback_response'];
    systemPrompt = json['system_prompt'];
    query = json['query'];
    releventContext = json['relevent_context'];
    topCount = json['top_count'];
    threadHold = json['thread_hold'];
    collectionName = json['collection_name'];
    temperature = json['temperature'];
    lang = json['lang'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    slots = json['slots'];
    history = json['history'];
    intentqueue = json['intentqueue'];
    chatbotName = json['chatbot_name'];
    promptContent = json['prompt_content'];
    customizePrompt = json['customize_prompt'];
    promptId = json['prompt_id'];
    progress = json['progress'];
    defaultConfigs = json['default_configs'];
    slotsConfig = json['slots_config'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chatbot_code'] = chatbotCode;
    data['user_industry'] = userIndustry;
    data['query_rewrite'] = queryRewrite;
    data['model_rerank'] = modelRerank;
    data['model_generate'] = modelGenerate;
    data['fallback_response'] = fallbackResponse;
    data['system_prompt'] = systemPrompt;
    data['query'] = query;
    data['relevent_context'] = releventContext;
    data['top_count'] = topCount;
    data['thread_hold'] = threadHold;
    data['collection_name'] = collectionName;
    data['temperature'] = temperature;
    data['lang'] = lang;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['slots'] = slots;
    data['history'] = history;
    data['intentqueue'] = intentqueue;
    data['chatbot_name'] = chatbotName;
    data['prompt_content'] = promptContent;
    data['customize_prompt'] = customizePrompt;
    data['prompt_id'] = promptId;
    data['progress'] = progress;
    data['default_configs'] = defaultConfigs;
    data['slots_config'] = slotsConfig;
    return data;
  }
}

// Định nghĩa model cho SlotsConfig
class SlotConfig {
  String? id;
  int? count;
  String? active;
  String? intentSlots;
  Map<String, dynamic>? slotDetails;

  SlotConfig({
    this.id,
    this.count,
    this.active,
    this.intentSlots,
    this.slotDetails,
  });

  factory SlotConfig.fromJson(Map<String, dynamic> json) {
    return SlotConfig(
      id: json['id'],
      count: json['count'],
      active: json['active'],
      intentSlots: json['intent_slots'],
      slotDetails: json['slot_details'] != null
          ? Map<String, dynamic>.from(json['slot_details'])
          : null,
    );
  }
}

