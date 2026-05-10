import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/backend/supabase_service.dart';
import '../../../core/config/app_config.dart';

class AdminPlayer {
  final String id;
  String name;
  final String email;
  int gold;
  int points;
  int level;
  String status;
  String element;
  DateTime lastActive;
  DateTime createdAt;
  bool isAnonymous;
  bool isBanned;

  AdminPlayer({
    required this.id,
    required this.name,
    required this.email,
    required this.gold,
    required this.points,
    required this.level,
    required this.status,
    required this.element,
    required this.lastActive,
    required this.createdAt,
    required this.isAnonymous,
    required this.isBanned,
  });

  factory AdminPlayer.fromJson(Map<String, dynamic> json) {
    final lastPlayStr = json['last_play_date'];
    final updatedAtStr = json['updated_at'];
    final joinedAtStr = json['joined_at'];

    final lastActive = lastPlayStr != null
        ? DateTime.parse(lastPlayStr)
        : (updatedAtStr != null
              ? DateTime.parse(updatedAtStr)
              : DateTime.now());

    final createdAt = joinedAtStr != null
        ? DateTime.parse(joinedAtStr)
        : (lastPlayStr != null
              ? DateTime.parse(lastPlayStr)
              : (updatedAtStr != null
                    ? DateTime.parse(updatedAtStr)
                    : DateTime.now()));

    final isBanned = json['is_banned'] == true;

    return AdminPlayer(
      id: json['id'] ?? '',
      name: json['username'] ?? 'Unknown',
      email: json['email'] ?? '',
      gold: json['iaw_balance'] ?? 0,
      points: json['points'] ?? 0,
      level: json['level'] ?? 1,
      status: isBanned ? 'Banned' : 'Active',
      element: json['element'] ?? '',
      lastActive: lastActive,
      createdAt: createdAt,
      isAnonymous: (json['is_anonymous'] ?? true) &&
          (json['email'] ?? '').toString().trim().isEmpty,
      isBanned: isBanned,
    );
  }
}

class LevelResult {
  final int points;
  final int level;
  LevelResult({required this.points, required this.level});
}

class AdminFeedback {
  final String id;
  final String playerId;
  final String playerName;
  final String message;
  final DateTime timestamp;
  String status;
  String? replyText;

  AdminFeedback({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.message,
    required this.timestamp,
    required this.status,
    this.replyText,
  });

  factory AdminFeedback.fromJson(Map<String, dynamic> json) {
    return AdminFeedback(
      id: json['id'],
      playerId: json['player_id'],
      playerName: json['profiles']?['username'] ?? 'Unknown Player',
      message: json['message'],
      timestamp: DateTime.parse(json['created_at']),
      status: json['status'] ?? 'unread',
      replyText: json['reply_text'],
    );
  }
}

class AdminAnnouncement {
  final String id;
  String title;
  String content;
  String type; // 'info', 'event', 'warning'
  bool isActive;
  DateTime createdAt;
  DateTime? expiresAt;
  Map<String, dynamic> metadata;

  AdminAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
    this.metadata = const {},
  });

  factory AdminAnnouncement.fromJson(Map<String, dynamic> json) {
    return AdminAnnouncement(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'info',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'type': type,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }
}

class AdminCardPack {
  final String id;
  String name;
  String description;
  int costGold;
  int cardsPerPack;
  String? guaranteedRarity;
  String? elementFocus;
  Map<String, dynamic> dropRates;
  bool isActive;
  bool requiresAd;
  bool hasCooldown;
  double cooldownHours;
  int purchaseLimit;
  bool isStarter;

  AdminCardPack({
    required this.id,
    required this.name,
    this.description = '',
    this.costGold = 100,
    this.cardsPerPack = 3,
    this.guaranteedRarity,
    this.elementFocus,
    required this.dropRates,
    this.isActive = true,
    this.requiresAd = false,
    this.hasCooldown = false,
    this.cooldownHours = 0.0,
    this.purchaseLimit = -1,
    this.isStarter = false,
  });

  factory AdminCardPack.fromJson(Map<String, dynamic> json) {
    return AdminCardPack(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      costGold: json['cost_gold'] ?? 100,
      cardsPerPack: json['cards_per_pack'] ?? 3,
      guaranteedRarity: json['guaranteed_rarity'],
      elementFocus: json['element_focus'],
      dropRates: json['drop_rates_json'] ?? {},
      isActive: json['is_active'] ?? true,
      requiresAd: json['requires_ad'] ?? false,
      hasCooldown: json['has_cooldown'] ?? false,
      cooldownHours: (json['cooldown_hours'] ?? 0).toDouble(),
      purchaseLimit: json['purchase_limit'] ?? -1,
      isStarter: json['is_starter'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'cost_gold': costGold,
      'cards_per_pack': cardsPerPack,
      'guaranteed_rarity': guaranteedRarity,
      'element_focus': elementFocus,
      'drop_rates_json': dropRates,
      'is_active': isActive,
      'requires_ad': requiresAd,
      'has_cooldown': hasCooldown,
      'cooldown_hours': cooldownHours,
      'purchase_limit': purchaseLimit,
      'is_starter': isStarter,
    };
  }
}

class AdminDailyReward {
  final int dayIndex;
  String rewardType; // 'xp', 'gold', 'pack'
  int amount;
  String? packId;
  String? title;

  AdminDailyReward({
    required this.dayIndex,
    required this.rewardType,
    this.amount = 0,
    this.packId,
    this.title,
  });

  factory AdminDailyReward.fromJson(Map<String, dynamic> json) {
    return AdminDailyReward(
      dayIndex: json['day_index'],
      rewardType: json['reward_type'],
      amount: json['amount'] ?? 0,
      packId: json['pack_id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reward_type': rewardType,
      'amount': amount,
      'pack_id': packId,
      'title': title,
    };
  }
}

class AdminAchievement {
  final String id;
  String nameDe;
  String nameEn;
  String descriptionDe;
  String descriptionEn;
  String icon;
  String category;
  Map<String, dynamic> criteria;
  bool isActive;
  Map<String, dynamic> translations;
  DateTime createdAt;

  AdminAchievement({
    required this.id,
    required this.nameDe,
    required this.nameEn,
    required this.descriptionDe,
    required this.descriptionEn,
    this.icon = 'emoji_events',
    this.category = 'general',
    required this.criteria,
    this.isActive = true,
    this.translations = const {},
    required this.createdAt,
  });

  factory AdminAchievement.fromJson(Map<String, dynamic> json) {
    return AdminAchievement(
      id: json['id'],
      nameDe: json['name_de'] ?? '',
      nameEn: json['name_en'] ?? '',
      descriptionDe: json['description_de'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      icon: json['icon'] ?? 'emoji_events',
      category: json['category'] ?? 'general',
      criteria: json['criteria'] ?? {},
      isActive: json['is_active'] ?? true,
      translations: json['translations'] ?? {},
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name_de': nameDe,
      'name_en': nameEn,
      'description_de': descriptionDe,
      'description_en': descriptionEn,
      'icon': icon,
      'category': category,
      'criteria': criteria,
      'is_active': isActive,
      'translations': translations,
    };
  }
}

class AdminCardTemplate {
  final String id;
  String name;
  String archetype;
  int tier;
  String element;
  int baseAtk;
  int baseDef;
  int baseAgi;
  String? lore;
  String? imagePrompt;
  Map<String, dynamic>? valuation;
  Map<String, dynamic> translations;

  AdminCardTemplate({
    required this.id,
    required this.name,
    required this.archetype,
    required this.tier,
    required this.element,
    required this.baseAtk,
    required this.baseDef,
    required this.baseAgi,
    this.lore,
    this.imagePrompt,
    this.valuation,
    this.translations = const {},
  });

  factory AdminCardTemplate.fromJson(Map<String, dynamic> json) {
    return AdminCardTemplate(
      id: json['id'],
      name: json['name'] ?? '',
      archetype: json['archetype'] ?? 'Warrior',
      tier: json['tier'] ?? 1,
      element: json['element'] ?? 'Neutral',
      baseAtk: json['base_atk'] ?? 10,
      baseDef: json['base_def'] ?? 10,
      baseAgi: json['base_agi'] ?? 10,
      lore: json['lore'],
      imagePrompt: json['image_prompt'],
      valuation: json['valuation'] as Map<String, dynamic>?,
      translations: json['translations'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'archetype': archetype,
      'tier': tier,
      'element': element,
      'base_atk': baseAtk,
      'base_def': baseDef,
      'base_agi': baseAgi,
      'lore': lore,
      'image_prompt': imagePrompt,
      'valuation': valuation,
      'translations': translations,
    };
  }
}

class AdminQuest {
  final String id;
  String title;
  String? description;
  String questType;
  String targetAction;
  int targetAmount;
  int rewardGold;
  int rewardPoints;
  String? rewardPackId;
  bool isActive;
  String icon;
  String color;
  int? minLevel;
  int? maxLevel;
  Map<String, dynamic> translations;

  AdminQuest({
    required this.id,
    required this.title,
    this.description,
    required this.questType,
    required this.targetAction,
    this.targetAmount = 1,
    this.rewardGold = 0,
    this.rewardPoints = 0,
    this.rewardPackId,
    this.isActive = true,
    this.icon = 'task',
    this.color = '#4CAF50',
    this.minLevel,
    this.maxLevel,
    this.translations = const {},
  });

  factory AdminQuest.fromJson(Map<String, dynamic> json) {
    return AdminQuest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      questType: json['quest_type'],
      targetAction: json['target_action'],
      targetAmount: json['target_amount'] ?? 1,
      rewardGold: json['reward_gold'] ?? 0,
      rewardPoints: json['reward_points'] ?? 0,
      rewardPackId: json['reward_pack_id'],
      isActive: json['is_active'] ?? true,
      icon: json['icon'] ?? 'task',
      color: json['color'] ?? '#4CAF50',
      minLevel: json['min_level'],
      maxLevel: json['max_level'],
      translations: json['translations'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'quest_type': questType,
      'target_action': targetAction,
      'target_amount': targetAmount,
      'reward_gold': rewardGold,
      'reward_points': rewardPoints,
      'reward_pack_id': rewardPackId,
      'is_active': isActive,
      'icon': icon,
      'color': color,
      'min_level': minLevel,
      'max_level': maxLevel,
      'translations': translations,
    };
  }
}

class AdminPushNotification {
  final String id;
  final String title;
  final String body;
  final String? targetAudience;
  final String? targetPlayerId;
  final int deviceCount;
  final Map<String, dynamic> filters;
  final DateTime sentAt;
  final String? sentBy;

  AdminPushNotification({
    required this.id,
    required this.title,
    required this.body,
    this.targetAudience,
    this.targetPlayerId,
    this.deviceCount = 0,
    this.filters = const {},
    required this.sentAt,
    this.sentBy,
  });

  factory AdminPushNotification.fromJson(Map<String, dynamic> json) {
    return AdminPushNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      targetAudience: json['target_audience'],
      targetPlayerId: json['target_player_id'],
      deviceCount: json['device_count'] ?? 0,
      filters: Map<String, dynamic>.from(json['filters'] ?? {}),
      sentAt: DateTime.parse(json['sent_at']),
      sentBy: json['sent_by'],
    );
  }
}

class AdminPushPreset {
  final String id;
  final String name;
  final Map<String, dynamic> filters;

  AdminPushPreset({
    required this.id,
    required this.name,
    required this.filters,
  });

  factory AdminPushPreset.fromJson(Map<String, dynamic> json) {
    return AdminPushPreset(
      id: json['id'],
      name: json['name'],
      filters: Map<String, dynamic>.from(json['filters'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'filters': filters};
  }
}

class AdminController extends GetxController {
  static AdminController get to => Get.find();

  // Default Valuations based on Tier
  static const Map<int, Map<String, dynamic>> defaultValuations = {
    1: {
      "bronze": {"min": 10, "exp": 15, "max": 20},
      "silver": {"min": 60, "exp": 80, "max": 100},
      "gold": {"min": 350, "exp": 450, "max": 550},
      "diamond": {"min": 2000, "exp": 2500, "max": 3000},
    },
    2: {
      "bronze": {"min": 15, "exp": 20, "max": 25},
      "silver": {"min": 80, "exp": 100, "max": 130},
      "gold": {"min": 450, "exp": 550, "max": 650},
      "diamond": {"min": 2500, "exp": 3500, "max": 4500},
    },
    3: {
      "bronze": {"min": 25, "exp": 30, "max": 35},
      "silver": {"min": 120, "exp": 140, "max": 160},
      "gold": {"min": 600, "exp": 700, "max": 800},
      "diamond": {"min": 4000, "exp": 4500, "max": 5500},
    },
    4: {
      "bronze": {"min": 30, "exp": 40, "max": 45},
      "silver": {"min": 140, "exp": 180, "max": 220},
      "gold": {"min": 700, "exp": 850, "max": 1000},
      "diamond": {"min": 5000, "exp": 6000, "max": 7500},
    },
  };

  final currentView = 'Dashboard'.obs;

  // Leveling Logic Helper (Matches main app cumulative logic)
  static LevelResult syncPointsAndLevel(int totalPoints, int currentLevel) {
    int newLevel = 1;

    // Level up check
    // Formula: Threshold(L) = 50 * L * (L-1)
    // Level 2: 100
    // Level 3: 300
    // Level 4: 600
    while (totalPoints >= 50 * (newLevel + 1) * newLevel) {
      newLevel++;
    }

    return LevelResult(points: totalPoints, level: newLevel);
  }

  // Real Data
  final players = <AdminPlayer>[].obs;

  final feedback = <AdminFeedback>[].obs;

  final pushNotifications = <AdminPushNotification>[].obs;
  final pushPresets = <AdminPushPreset>[].obs;

  final stats = <String, dynamic>{
    'Total Players': 0,
    'Active Today': 0,
    'Total Gold': 0,
    'Avg. Level': 0.0,
    'Unread Feedback': 0,
  }.obs;

  // Selection for Bulk Actions
  final selectedPlayerIds = <String>{}.obs;

  // Optimized Filtering & Sorting
  final cardSearchQuery = ''.obs;
  final cardElementFilter = RxnString();
  final cardSortColumn = RxnInt();
  final cardSortAscending = true.obs;

  final playerSearchQuery = ''.obs;
  final playerSortColumn = RxnInt();
  final playerSortAscending = true.obs;

  List<AdminCardTemplate> get filteredCardTemplates {
    final query = cardSearchQuery.value.toLowerCase();
    final element = cardElementFilter.value;

    var list = cardTemplates.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(query);
      final matchesElement = element == null || c.element == element;
      return matchesSearch && matchesElement;
    }).toList();

    if (cardSortColumn.value != null) {
      list.sort((a, b) {
        int cmp;
        switch (cardSortColumn.value) {
          case 0:
            cmp = a.name.compareTo(b.name);
            break;
          case 1:
            cmp = a.element.compareTo(b.element);
            break;
          case 2:
            cmp = a.tier.compareTo(b.tier);
            break;
          case 3:
            cmp = a.baseAtk.compareTo(b.baseAtk);
            break;
          case 4:
            cmp = a.baseDef.compareTo(b.baseDef);
            break;
          case 5:
            cmp = a.baseAgi.compareTo(b.baseAgi);
            break;
          default:
            cmp = 0;
        }
        return cardSortAscending.value ? cmp : -cmp;
      });
    }
    return list;
  }

  List<AdminPlayer> get filteredPlayers {
    final query = playerSearchQuery.value.toLowerCase();

    var list = players.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.email.toLowerCase().contains(query);
    }).toList();

    if (playerSortColumn.value != null) {
      list.sort((a, b) {
        int cmp;
        switch (playerSortColumn.value) {
          case 0:
            cmp = a.name.compareTo(b.name);
            break;
          case 1:
            cmp = (a.isAnonymous ? 1 : 0).compareTo(b.isAnonymous ? 1 : 0);
            break;
          case 2:
            cmp = a.gold.compareTo(b.gold);
            break;
          case 3:
            cmp = a.points.compareTo(b.points);
            break;
          case 4:
            cmp = a.level.compareTo(b.level);
            break;
          case 5:
            cmp = a.status.compareTo(b.status);
            break;
          case 6:
            cmp = a.createdAt.compareTo(b.createdAt);
            break;
          case 7:
            cmp = a.lastActive.compareTo(b.lastActive);
            break;
          default:
            cmp = 0;
        }
        return playerSortAscending.value ? cmp : -cmp;
      });
    }
    return list;
  }

  final balancingConfig = <String, dynamic>{}.obs;
  final changedKeys = <String>{}.obs; // Track only what changed
  final cardPacks = <AdminCardPack>[].obs;
  final cardTemplates = <AdminCardTemplate>[].obs;
  final announcements = <AdminAnnouncement>[].obs;
  final quests = <AdminQuest>[].obs;
  final dailyRewards = <AdminDailyReward>[].obs;
  final achievements = <AdminAchievement>[].obs;
  final extendedStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPlayers();
    _loadBalancingConfig();
    _loadCardPacks();
    _loadCardTemplates();
    _loadQuests();
    _loadFeedback();
    _loadAnnouncements();
    _loadPushNotifications();
    _loadPushPresets();
    _loadDailyRewards();
    _loadAchievements();
    _loadExtendedAnalytics();
  }

  Future<void> _loadExtendedAnalytics() async {
    try {
      debugPrint('📊 Loading extended analytics (RPC)...');

      final response = await SupabaseService.to.client
          .rpc('get_admin_analytics');

      if (response != null) {
        final data = response as Map<String, dynamic>;
        
        // Map the RPC response directly to our extendedStats
        extendedStats.value = {
          'total_cards': data['total_cards'] ?? 0,
          'rarity': Map<String, int>.from(data['rarity'] ?? {}),
          'quests_completed': data['quests_completed'] ?? 0,
          'elements': Map<String, int>.from(data['elements'] ?? {}),
          'new_7d': data['new_7d'] ?? 0,
          'registered': data['registered'] ?? 0,
          'anonymous': data['anonymous'] ?? 0,
          'banned': data['banned'] ?? 0,
          'fcm_tokens': data['fcm_tokens'] ?? 0,
          'updated_at': DateTime.now().toLocal().toString().split('.')[0],
        };
        
        debugPrint('✅ Analytics loaded via RPC');
      }
    } catch (e) {
      debugPrint('❌ Error loading extended analytics: $e');
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      _loadPlayers(),
      _loadBalancingConfig(),
      _loadCardPacks(),
      _loadCardTemplates(),
      _loadQuests(),
      _loadFeedback(),
      _loadAnnouncements(),
      _loadPushNotifications(),
      _loadPushPresets(),
      _loadExtendedAnalytics(),
    ]);
  }

  Future<void> _loadAnnouncements() async {
    try {
      final response = await SupabaseService.to.client
          .from('announcements')
          .select()
          .order('created_at', ascending: false);

      announcements.assignAll(
        (response as List)
            .map(
              (e) => AdminAnnouncement.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
      );
    } catch (e) {
      debugPrint('❌ Error loading announcements: $e');
    }
  }

  Future<void> _loadFeedback() async {
    try {
      final response = await SupabaseService.to.client
          .from('player_feedback')
          .select('*, profiles(username)')
          .order('created_at', ascending: false);

      feedback.assignAll(
        (response as List)
            .map((e) => AdminFeedback.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
      _updateDashboardStats();
    } catch (e) {
      debugPrint('❌ Error loading feedback: $e');
    }
  }

  Future<void> _loadPlayers() async {
    try {
      final response = await SupabaseService.to.client
          .from('profiles')
          .select()
          .order('username', ascending: true);
      players.assignAll(
        (response as List)
            .map((e) => AdminPlayer.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
      _updateDashboardStats();
    } catch (e) {
      debugPrint('❌ Error loading players: $e');
      Get.snackbar(
        'Error',
        'Failed to load players: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _loadQuests() async {
    try {
      final response = await SupabaseService.to.client
          .from('quests')
          .select()
          .order('created_at', ascending: false);
      quests.assignAll(
        (response as List)
            .map((e) => AdminQuest.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } catch (e) {
      debugPrint('❌ Error loading quests: $e');
    }
  }

  Future<void> _loadCardTemplates() async {
    try {
      final response = await SupabaseService.to.client
          .from('card_templates')
          .select()
          .order('name', ascending: true);
      cardTemplates.assignAll(
        (response as List)
            .map(
              (e) => AdminCardTemplate.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
      );
    } catch (e) {
      debugPrint('❌ Error loading card templates: $e');
      Get.snackbar(
        'Error',
        'Failed to load card templates: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _loadCardPacks() async {
    try {
      final response = await SupabaseService.to.client
          .from('card_packs')
          .select()
          .order('created_at', ascending: true);
      cardPacks.assignAll(
        (response as List)
            .map((e) => AdminCardPack.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } catch (e) {
      debugPrint('❌ Error loading card packs: $e');
      Get.snackbar(
        'Error',
        'Failed to load card packs: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _loadBalancingConfig() async {
    try {
      final response = await SupabaseService.to.client
          .from('game_config')
          .select();
      final configMap = <String, dynamic>{};

      for (var row in response) {
        final rowMap = Map<String, dynamic>.from(row);
        final String key = rowMap['key_name'] as String;
        // value_number has priority, then value_string
        final dynamic val = rowMap['value_number'] ?? rowMap['value_string'];
        if (val != null) {
          configMap[key] = val;
        }
      }

      balancingConfig.assignAll(configMap);
    } catch (e) {
      debugPrint('❌ Error loading game config: $e');
      Get.snackbar(
        'Error',
        'Failed to load game config: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void setView(String view) {
    currentView.value = view;
    // Clear selection when view changes
    selectedPlayerIds.clear();
  }

  void togglePlayerSelection(String id) {
    if (selectedPlayerIds.contains(id)) {
      selectedPlayerIds.remove(id);
    } else {
      selectedPlayerIds.add(id);
    }
  }

  void selectAllPlayers(bool select) {
    if (select) {
      selectedPlayerIds.assignAll(filteredPlayers.map((p) => p.id));
    } else {
      selectedPlayerIds.clear();
    }
  }

  void updateMultiplierLocal(String key, double value) {
    // Update local state immediately for fast UI feedback
    if (balancingConfig[key] != value) {
      balancingConfig[key] = value;
      changedKeys.add(key);
    }
  }

  Future<Map<String, dynamic>?> simulatePackOpening(
    String packId, {
    int iterations = 1,
  }) async {
    try {
      final response = await SupabaseService.to.client.rpc(
        'simulate_card_pack_opening',
        params: {'p_pack_id': packId, 'p_iterations': iterations},
      );
      return Map<String, dynamic>.from(response);
    } catch (e) {
      debugPrint('❌ Error simulating pack opening: $e');
      Get.snackbar(
        'Simulation Error',
        'Failed to run simulation: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<void> saveBalancingConfig() async {
    if (changedKeys.isEmpty) {
      Get.snackbar(
        'Info',
        'Keine Änderungen zum Speichern vorhanden.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      Get.snackbar(
        'Processing',
        'Saving ${changedKeys.length} changes...',
        snackPosition: SnackPosition.BOTTOM,
      );

      // We only update keys that actually changed
      for (var key in changedKeys.toList()) {
        final value = balancingConfig[key];
        final updateData = <String, dynamic>{};
        if (value is num) {
          updateData['value_number'] = value;
        } else {
          updateData['value_string'] = value.toString();
        }

        final result = await SupabaseService.to.client
            .from('game_config')
            .update(updateData)
            .eq('key_name', key)
            .select();

        if (result == null || (result as List).isEmpty) {
          debugPrint(
            '⚠️ Warning: No row updated for key: $key. This might be due to RLS or a missing key.',
          );
        } else {
          debugPrint('✅ Updated key: $key to $value');
        }
      }

      changedKeys.clear();

      Get.snackbar(
        'Success',
        'Configuration saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      // Force sync status update
      _updateSyncStatus('game_config');
    } catch (e) {
      debugPrint('❌ Error saving game config: $e');
      Get.snackbar(
        'Error',
        'Failed to save configuration: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> saveCardPack(AdminCardPack pack) async {
    try {
      if (pack.id.isEmpty || pack.id == 'new') {
        await SupabaseService.to.client
            .from('card_packs')
            .insert(pack.toJson());
      } else {
        await SupabaseService.to.client
            .from('card_packs')
            .update(pack.toJson())
            .eq('id', pack.id);
      }
      _loadCardPacks(); // Refresh
      Get.snackbar(
        'Success',
        'Pack saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Force sync status update
      _updateSyncStatus('card_packs');
    } catch (e) {
      debugPrint('❌ Error saving pack: $e');
      Get.snackbar(
        'Error',
        'Failed to save pack: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteCardPack(String id) async {
    try {
      await SupabaseService.to.client.from('card_packs').delete().eq('id', id);
      _loadCardPacks();
      Get.snackbar(
        'Success',
        'Pack deleted',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Force sync status update
      _updateSyncStatus('card_packs');
    } catch (e) {
      debugPrint('❌ Error deleting pack: $e');
      Get.snackbar(
        'Error',
        'Failed to delete pack: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> saveCardTemplate(AdminCardTemplate template) async {
    try {
      if (template.id.isEmpty || template.id == 'new') {
        await SupabaseService.to.client
            .from('card_templates')
            .insert(template.toJson());
      } else {
        await SupabaseService.to.client
            .from('card_templates')
            .update(template.toJson())
            .eq('id', template.id);
      }
      _loadCardTemplates(); // Refresh
      Get.snackbar(
        'Success',
        'Card template saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      _updateSyncStatus('card_templates');
    } catch (e) {
      debugPrint('❌ Error saving card template: $e');
      Get.snackbar(
        'Error',
        'Failed to save card template: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteCardTemplate(String id) async {
    try {
      await SupabaseService.to.client
          .from('card_templates')
          .delete()
          .eq('id', id);
      _loadCardTemplates();
      Get.snackbar(
        'Success',
        'Card template deleted',
        snackPosition: SnackPosition.BOTTOM,
      );

      _updateSyncStatus('card_templates');
    } catch (e) {
      debugPrint('❌ Error deleting card template: $e');
      Get.snackbar(
        'Error',
        'Failed to delete card template: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> saveQuest(AdminQuest quest) async {
    try {
      if (quest.id.isEmpty || quest.id == 'new') {
        await SupabaseService.to.client.from('quests').insert(quest.toJson());
      } else {
        await SupabaseService.to.client
            .from('quests')
            .update(quest.toJson())
            .eq('id', quest.id);
      }
      _loadQuests();
      Get.snackbar(
        'Success',
        'Quest saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      _updateSyncStatus('quests');
    } catch (e) {
      debugPrint('❌ Error saving quest: $e');
      Get.snackbar(
        'Error',
        'Failed to save quest: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteQuest(String id) async {
    try {
      await SupabaseService.to.client.from('quests').delete().eq('id', id);
      _loadQuests();
      Get.snackbar(
        'Success',
        'Quest deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
      _updateSyncStatus('quests');
    } catch (e) {
      debugPrint('❌ Error deleting quest: $e');
      Get.snackbar(
        'Error',
        'Failed to delete quest: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updatePlayer(AdminPlayer player) async {
    try {
      // 1. Update metadata (username, ban status) - This is allowed via normal API
      final Map<String, dynamic> metadataUpdates = {'username': player.name};

      try {
        await SupabaseService.to.client
            .from('profiles')
            .update({
              ...metadataUpdates,
              'is_banned': player.status == 'Banned',
            })
            .eq('id', player.id);
      } catch (e) {
        if (e.toString().contains('is_banned')) {
          debugPrint(
            '⚠️ Warning: is_banned column missing, updating metadata only.',
          );
          await SupabaseService.to.client
              .from('profiles')
              .update(metadataUpdates)
              .eq('id', player.id);
        } else {
          rethrow;
        }
      }

      // 2. Update protected stats (gold, xp, level) via Admin RPC
      // Normal UPDATE on these columns is now blocked for security.
      final result = await SupabaseService.to.client.rpc(
        'admin_set_player_stats',
        params: {
          'p_player_id': player.id,
          'p_new_gold': player.gold,
          'p_new_xp': player.points,
          'p_new_level': player.level,
        },
      );

      if (result['success'] == true) {
        _loadPlayers(); // Refresh list
        Get.snackbar(
          'Success',
          'Player updated successfully (including protected stats)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Fehler',
          result['error'] ?? 'Stats konnten nicht gesetzt werden.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating player: $e');
      Get.snackbar(
        'Error',
        'Failed to update player: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deletePlayer(String id) async {
    try {
      await SupabaseService.to.client.rpc(
        'delete_user_entirely',
        params: {'target_user_id': id},
      );
      selectedPlayerIds.remove(id); // Clean up if it was selected
      _loadPlayers(); // Refresh list
      Get.snackbar(
        'Success',
        'Player and all data deleted.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('❌ Error deleting player: $e');
      Get.snackbar(
        'Error',
        'Failed to delete player: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deletePlayersBulk() async {
    if (selectedPlayerIds.isEmpty) return;

    final idsToDelete = selectedPlayerIds.toList();
    try {
      Get.snackbar(
        'Processing',
        'Deleting ${idsToDelete.length} players...',
        snackPosition: SnackPosition.BOTTOM,
        showProgressIndicator: true,
      );

      for (var id in idsToDelete) {
        await SupabaseService.to.client.rpc(
          'delete_user_entirely',
          params: {'target_user_id': id},
        );
      }

      selectedPlayerIds.clear();
      _loadPlayers();

      Get.snackbar(
        'Success',
        '${idsToDelete.length} players deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      debugPrint('❌ Error in bulk delete: $e');
      Get.snackbar(
        'Error',
        'Partial failure: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateFeedbackStatus(
    String id,
    String status, {
    String? replyText,
  }) async {
    try {
      final data = {'status': status};
      if (replyText != null) data['reply_text'] = replyText;

      await SupabaseService.to.client
          .from('player_feedback')
          .update(data)
          .eq('id', id);
      _loadFeedback(); // Refresh
      Get.snackbar(
        'Success',
        'Feedback updated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('❌ Error updating feedback: $e');
    }
  }

  Future<void> saveAnnouncement(AdminAnnouncement announcement) async {
    try {
      if (announcement.id == 'new') {
        await SupabaseService.to.client
            .from('announcements')
            .insert(announcement.toJson());
      } else {
        await SupabaseService.to.client
            .from('announcements')
            .update(announcement.toJson())
            .eq('id', announcement.id);
      }
      _loadAnnouncements();
      Get.snackbar(
        'Success',
        'Announcement saved',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('❌ Error saving announcement: $e');
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await SupabaseService.to.client
          .from('announcements')
          .delete()
          .eq('id', id);
      _loadAnnouncements();
      Get.snackbar(
        'Success',
        'Announcement deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('❌ Error deleting announcement: $e');
    }
  }

  Future<void> _loadPushNotifications() async {
    try {
      final res = await SupabaseService.to.client
          .from('push_notifications')
          .select()
          .order('sent_at', ascending: false);
      pushNotifications.assignAll(
        (res as List)
            .map(
              (n) =>
                  AdminPushNotification.fromJson(Map<String, dynamic>.from(n)),
            )
            .toList(),
      );
    } catch (e) {
      debugPrint('❌ Error loading push notifications: $e');
    }
  }

  Future<void> _loadPushPresets() async {
    try {
      final res = await SupabaseService.to.client
          .from('push_notification_presets')
          .select()
          .order('name');
      pushPresets.assignAll(
        (res as List)
            .map((p) => AdminPushPreset.fromJson(Map<String, dynamic>.from(p)))
            .toList(),
      );
    } catch (e) {
      debugPrint('❌ Error loading push presets: $e');
    }
  }

  Future<void> savePushPreset(String name, Map<String, dynamic> filters) async {
    try {
      await SupabaseService.to.client.from('push_notification_presets').insert({
        'name': name,
        'filters': filters,
      });
      _loadPushPresets();
      Get.snackbar('Success', 'Preset "$name" saved');
    } catch (e) {
      debugPrint('❌ Error saving push preset: $e');
      Get.snackbar('Error', 'Failed to save preset');
    }
  }

  Future<void> deletePushPreset(String id) async {
    try {
      await SupabaseService.to.client
          .from('push_notification_presets')
          .delete()
          .eq('id', id);
      _loadPushPresets();
      Get.snackbar('Success', 'Preset deleted');
    } catch (e) {
      debugPrint('❌ Error deleting push preset: $e');
    }
  }

  Future<void> sendPushNotification({
    required String title,
    required String body,
    String? playerId,
    bool isGlobal = false,
    Map<String, dynamic>? filters,
  }) async {
    final session = SupabaseService.to.client.auth.currentSession;
    if (session == null) {
      Get.snackbar(
        'Error',
        'Session lost. Please log in again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // 1. Validation
      if (!isGlobal && playerId == null && (filters == null || filters.isEmpty)) {
        Get.snackbar(
          'Error',
          'No target audience selected. Please choose Global, Filter, or a Specific Player.',
          backgroundColor: Colors.orange,
          colorText: Colors.black,
        );
        return;
      }

      // Safe logging for web browsers
      try {
        debugPrint('📣 Push Request -> Global: $isGlobal, Player: $playerId, Filters: ${filters?.keys.join(',')}');
      } catch (e) {
        debugPrint('📣 Attempting to send push...');
      }

      final response = await SupabaseService.to.client.functions.invoke(
        'send-push',
        body: {
          'title': title,
          'body': body,
          'player_id': playerId,
          'is_global': isGlobal,
          'filters': filters,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.status == 200) {
        Get.snackbar(
          'Success',
          'Notification sent successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        _loadPushNotifications(); // Refresh list
      } else {
        final errorText = response.data is Map
            ? (response.data['error'] ?? 'Unknown error')
            : 'Status ${response.status}';
        Get.snackbar(
          'Error',
          'Failed to send: $errorText',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error sending push: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _updateDashboardStats() {
    if (players.isEmpty) return;

    final now = DateTime.now();
    final oneDayAgo = now.subtract(const Duration(hours: 24));

    // Calculate metrics
    final totalPlayers = players.length;
    final activeToday = players
        .where((p) => p.lastActive.isAfter(oneDayAgo))
        .length;
    final totalGold = players.fold<int>(0, (sum, p) => sum + p.gold);
    final avgLevel = players.isEmpty
        ? 0.0
        : players.fold<int>(0, (sum, p) => sum + p.level) / totalPlayers;
    final unreadFeedback = feedback.where((f) => f.status == 'unread').length;

    // Update stats map
    stats.value = {
      'Total Players': totalPlayers,
      'Active Today': activeToday,
      'Total Gold': totalGold,
      'Avg. Level': double.parse(avgLevel.toStringAsFixed(1)),
      'Unread Feedback': unreadFeedback,
    };
    stats.refresh();
  }

  Future<void> fixMissingJoinedDates() async {
    try {
      Get.snackbar(
        'Processing',
        'Identifying users with missing joined_at...',
        snackPosition: SnackPosition.BOTTOM,
      );

      // 1. Fetch profiles where joined_at is null
      final response = await SupabaseService.to.client
          .from('profiles')
          .select('id, last_play_date, updated_at')
          .filter('joined_at', 'is', null);

      final brokenProfiles = response as List;
      if (brokenProfiles.isEmpty) {
        Get.snackbar(
          'Info',
          'No profiles found with missing joined_at.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      int fixedCount = 0;
      for (var row in brokenProfiles) {
        final id = row['id'];
        // Pick best available date
        final bestDateStr = row['last_play_date'] ?? row['updated_at'];

        if (bestDateStr != null) {
          await SupabaseService.to.client
              .from('profiles')
              .update({'joined_at': bestDateStr})
              .eq('id', id);
          fixedCount++;
        }
      }

      _loadPlayers(); // Refresh UI
      Get.snackbar(
        'Success',
        'Fixed $fixedCount profiles with missing joined_at.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('❌ Error fixing joined dates: $e');
      Get.snackbar(
        'Error',
        'Failed to fix data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _updateSyncStatus(String tableName) async {
    try {
      await SupabaseService.to.client.from('data_sync_status').upsert({
        'table_name': tableName,
        'last_updated': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('✅ Manual sync status updated for $tableName');
    } catch (e) {
      debugPrint('⚠️ Failed to update sync status for $tableName: $e');
    }
  }

  Future<void> _loadDailyRewards() async {
    try {
      final res = await SupabaseService.to.client
          .from('daily_reward_schedule')
          .select()
          .order('day_index', ascending: true);
      dailyRewards.assignAll(
        (res as List)
            .map((r) => AdminDailyReward.fromJson(Map<String, dynamic>.from(r)))
            .toList(),
      );
    } catch (e) {
      debugPrint('❌ Error loading daily rewards: $e');
    }
  }

  Future<void> saveDailyReward(AdminDailyReward reward) async {
    try {
      await SupabaseService.to.client
          .from('daily_reward_schedule')
          .update(reward.toJson())
          .eq('day_index', reward.dayIndex);
      
      _loadDailyRewards();
      Get.snackbar('Erfolg', 'Belohnung für Tag ${reward.dayIndex} gespeichert');
    } catch (e) {
      debugPrint('❌ Error saving daily reward: $e');
      Get.snackbar('Fehler', 'Konnte Belohnung nicht speichern');
    }
  }

  Future<void> _loadAchievements() async {
    try {
      final res = await SupabaseService.to.client
          .from('achievements')
          .select()
          .order('created_at', ascending: false);
      achievements.assignAll(
        (res as List)
            .map((r) => AdminAchievement.fromJson(Map<String, dynamic>.from(r)))
            .toList(),
      );
    } catch (e) {
      debugPrint('❌ Error loading achievements: $e');
    }
  }

  Future<void> saveAchievement(AdminAchievement achievement) async {
    try {
      if (achievement.id.startsWith('temp_')) {
        await SupabaseService.to.client
            .from('achievements')
            .insert(achievement.toJson());
      } else {
        await SupabaseService.to.client
            .from('achievements')
            .update(achievement.toJson())
            .eq('id', achievement.id);
      }
      _loadAchievements();
      Get.snackbar('Erfolg', 'Achievement gespeichert');
    } catch (e) {
      debugPrint('❌ Error saving achievement: $e');
      Get.snackbar('Fehler', 'Konnte Achievement nicht speichern');
    }
  }

  Future<void> deleteAchievement(String id) async {
    try {
      await SupabaseService.to.client.from('achievements').delete().eq('id', id);
      _loadAchievements();
      Get.snackbar('Erfolg', 'Achievement gelöscht');
    } catch (e) {
      debugPrint('❌ Error deleting achievement: $e');
      Get.snackbar('Fehler', 'Konnte Achievement nicht löschen');
    }
  }
}
