import 'package:flutter/material.dart';

import '../../utils/theme.dart';
import '../../widgets/common_widgets.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _postController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isAnonymous = false;

  final List<String> _categories = [
    'General',
    'Safety Alert',
    'Help Request',
    'Safe Places',
    'Transportation',
    'Support',
  ];

  // Mock data for community posts
  final List<Map<String, dynamic>> _communityPosts = [
    {
      'id': '1',
      'author': 'Sarah K.',
      'isAnonymous': false,
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'category': 'Safety Alert',
      'content':
          'Avoid the area near Central Park after 9 PM. Poor lighting and suspicious activity reported.',
      'location': 'Central Park Area',
      'likes': 15,
      'comments': 8,
      'isLiked': false,
      'priority': 'high',
    },
    {
      'id': '2',
      'author': 'Anonymous',
      'isAnonymous': true,
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
      'category': 'Help Request',
      'content':
          'Looking for a safe escort from the library to parking lot around 10 PM. Anyone available?',
      'location': 'University Library',
      'likes': 7,
      'comments': 12,
      'isLiked': true,
      'priority': 'medium',
    },
    {
      'id': '3',
      'author': 'Emma R.',
      'isAnonymous': false,
      'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
      'category': 'Safe Places',
      'content':
          'Highly recommend Café Luna on 5th Street. Well-lit, good security, and staff is very helpful. Great place to wait for rides.',
      'location': '5th Street',
      'likes': 23,
      'comments': 5,
      'isLiked': false,
      'priority': 'low',
    },
    {
      'id': '4',
      'author': 'Anonymous',
      'isAnonymous': true,
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'category': 'Transportation',
      'content':
          'Anyone know reliable female taxi drivers in the downtown area? Prefer women drivers for late night rides.',
      'location': 'Downtown',
      'likes': 11,
      'comments': 9,
      'isLiked': false,
      'priority': 'medium',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    super.dispose();
  }

  void _showCreatePostDialog() {
    _postController.clear();
    _selectedCategory = 'General';
    _isAnonymous = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create Post',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Category selection
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Post content
                TextField(
                  controller: _postController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'What\'s on your mind?',
                    hintText:
                        'Share safety tips, ask for help, or alert the community...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),

                // Anonymous posting option
                Row(
                  children: [
                    Checkbox(
                      value: _isAnonymous,
                      onChanged: (value) {
                        setState(() {
                          _isAnonymous = value!;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    const Text('Post anonymously'),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.secondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: 'Post',
                      onPressed: () {
                        if (_postController.text.isNotEmpty) {
                          // TODO: Add post to community
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Post shared with community'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      width: 80,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final priorityColor = post['priority'] == 'high'
        ? Colors.red
        : post['priority'] == 'medium'
            ? Colors.orange
            : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: post['isAnonymous']
                      ? Colors.grey[400]
                      : AppColors.primary,
                  child: Icon(
                    post['isAnonymous'] ? Icons.person : Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['author'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatTimestamp(post['timestamp']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: priorityColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    post['category'],
                    style: TextStyle(
                      fontSize: 10,
                      color: priorityColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            Text(
              post['content'],
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),

            // Location
            if (post['location'] != null)
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post['location'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                InkWell(
                  onTap: () {
                    // TODO: Toggle like
                  },
                  child: Row(
                    children: [
                      Icon(
                        post['isLiked']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20,
                        color: post['isLiked'] ? Colors.red : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post['likes']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    // TODO: Show comments
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post['comments']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    // TODO: Share post
                  },
                  child: Icon(
                    Icons.share_outlined,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyResourcesTab() {
    final resources = [
      {
        'title': 'Emergency Hotlines',
        'icon': Icons.phone,
        'items': [
          {'name': 'Police Emergency', 'number': '911'},
          {'name': 'Women\'s Helpline', 'number': '1-800-WOMEN'},
          {'name': 'Crisis Support', 'number': '1-800-CRISIS'},
        ],
      },
      {
        'title': 'Safety Tips',
        'icon': Icons.lightbulb_outline,
        'items': [
          {'name': 'Walking Alone at Night', 'tip': 'Stay in well-lit areas'},
          {'name': 'Public Transportation', 'tip': 'Sit near the driver'},
          {'name': 'Dating Safety', 'tip': 'Meet in public places first'},
        ],
      },
      {
        'title': 'Local Resources',
        'icon': Icons.location_city,
        'items': [
          {'name': 'Women\'s Shelter', 'address': '123 Safe Haven St'},
          {'name': 'Legal Aid Society', 'address': '456 Justice Ave'},
          {'name': 'Counseling Center', 'address': '789 Support Blvd'},
        ],
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(
                resource['icon'] as IconData,
                color: Colors.white,
              ),
            ),
            title: Text(
              resource['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            children: (resource['items'] as List).map((item) {
              return ListTile(
                dense: true,
                title: Text(item['name'] as String),
                subtitle: Text(
                  item['number'] ?? item['tip'] ?? item['address'] ?? '',
                ),
                trailing: item['number'] != null
                    ? IconButton(
                        onPressed: () {
                          // TODO: Make phone call
                        },
                        icon: const Icon(Icons.call),
                        color: AppColors.primary,
                      )
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Community Feed'),
            Tab(text: 'Safety Resources'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Search functionality
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Community Feed Tab
          Column(
            children: [
              // Quick stats banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '1.2K',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Active Users',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '450',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Posts Today',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '89%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Safety Score',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Posts list
              Expanded(
                child: ListView.builder(
                  itemCount: _communityPosts.length,
                  itemBuilder: (context, index) {
                    return _buildPostCard(_communityPosts[index]);
                  },
                ),
              ),
            ],
          ),

          // Safety Resources Tab
          _buildSafetyResourcesTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showCreatePostDialog,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
