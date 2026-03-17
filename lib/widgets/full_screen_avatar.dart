import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class _FullScreenAvatar extends StatelessWidget {
  final String uid;
  final String name;
  final String imageUrl;
  final bool   isOnline;

  const _FullScreenAvatar({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black87,
          child: SafeArea(
            child: Column(
              children: [


                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: AppTextStyles.headingSmall
                                    .copyWith(
                                  color: Colors.white,
                                )),
                            Row(
                              children: [
                                Container(
                                  width: 7, height: 7,
                                  decoration: BoxDecoration(
                                    color: isOnline
                                        ? AppColors.online
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isOnline ? 'Online' : 'Offline',
                                  style: AppTextStyles.caption
                                      .copyWith(
                                    color: isOnline
                                        ? AppColors.online
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),


                Expanded(
                  child: Center(
                    child: Hero(
                      tag: 'avatar_$uid',
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 280, height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withOpacity(0.3),
                                blurRadius:   30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit:      BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(
                                    color: AppColors.primary
                                        .withOpacity(0.15),
                                    child: const Center(
                                      child:
                                      CircularProgressIndicator(
                                        color: AppColors.primary,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                            )
                                : Container(
                              color: AppColors.primary
                                  .withOpacity(0.15),
                              child: Center(
                                child: Text(
                                  name.isNotEmpty
                                      ? name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color:    AppColors.primary,
                                    fontSize: 100,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}