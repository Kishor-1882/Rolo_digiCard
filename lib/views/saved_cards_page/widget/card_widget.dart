import 'package:flutter/material.dart';
import 'package:rolo_digi_card/utils/color.dart';

class BusinessCardWidget extends StatelessWidget {
  final String name;
  final String designation;
  final String company;
  final String savedDate;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback? onCardTap;
  final VoidCallback? onCheckboxTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onDownloadTap;
  final VoidCallback? onShareTap;
  final GestureTapDownCallback? onMenuTap;

  const BusinessCardWidget({
    Key? key,
    required this.name,
    required this.designation,
    required this.company,
    required this.savedDate,
    this.isSelected = false,
    this.isFavorite = false,
    this.onCardTap,
    this.onCheckboxTap,
    this.onFavoriteTap,
    this.onDownloadTap,
    this.onShareTap,
    this.onMenuTap,
  }) : super(key: key);

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    String initials = '';
    for (var n in names) {
      if (n.isNotEmpty) {
        initials += n[0].toUpperCase();
      }
    }
    return initials.length > 2 ? initials.substring(0, 2) : initials;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
            AppColors.gradientStart,
            AppColors.gradientEnd,
          ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:AppColors.textPrimary.withOpacity(0.10),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Checkbox
                GestureDetector(
                  onTap: onCheckboxTap,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: AppColors.textPrimary,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                        : null,
                  ),
                ),
                GestureDetector(
                  onTap: onFavoriteTap,
                  child: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.white : AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ],
            ),
                SizedBox(height: 10,),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.selectedBorder,
                            AppColors.switchBlue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(name),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    designation,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    company,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(

                                      border: Border.all(
                                        color:  AppColors.selectedBorder,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      onPressed: onDownloadTap,
                                      icon: Icon(
                                        Icons.download,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(

                                      border: Border.all(
                                        color:  AppColors.selectedBorder,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      onPressed: onShareTap,
                                      icon: Icon(
                                        Icons.share,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  SizedBox(width: 3,),
                                  GestureDetector(
                                    onTapDown: onMenuTap,
                                    child: Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ],
                              ),


                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            SizedBox(height: 10,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color:AppColors.textPrimary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.textPrimary.withOpacity(0.10),
                  )
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.pink,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Saved $savedDate',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}