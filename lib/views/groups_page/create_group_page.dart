import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/utils/color.dart';

import 'package:rolo_digi_card/controllers/individual_group_controller.dart';
import 'package:rolo_digi_card/models/group_model.dart';

class CreateGroupPage extends StatefulWidget {
  final GroupModel? group;
  const CreateGroupPage({Key? key, this.group}) : super(key: key);

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final IndividualGroupController controller = Get.find<IndividualGroupController>();

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      controller.nameController.text = widget.group!.name;
      controller.descriptionController.text = widget.group!.description ?? '';
    } else {
      controller.clearForm();
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground ?? const Color(0xFF14141E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                      
                          child:  Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.group != null ? 'Edit Personal Group' : 'Create Personal Group',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // const Spacer(),
                      // GestureDetector(
                      //   onTap: () => Get.back(),
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      //     decoration: BoxDecoration(
                      //       color: Colors.transparent,
                      //       borderRadius: BorderRadius.circular(8),
                      //       border: Border.all(color: Colors.white24),
                      //     ),
                      //     child: const Row(
                      //       children: [
                      //         Icon(Icons.arrow_back, color: Colors.white, size: 16),
                      //         SizedBox(width: 4),
                      //         Text(
                      //           'Back to Groups',
                      //           style: TextStyle(
                      //             color: Colors.white,
                      //             fontSize: 14,
                      //             fontWeight: FontWeight.w500,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Organize your cards into personal groups for better management',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C), // Dark card surface
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'Group Name ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'e.g. Personal Projects, Freelance Work',
                          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFF14141E), // darker background for input
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.descriptionController,
                        maxLines: 5,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 80.0), // Align top
                            child: Icon(Icons.description_outlined, color: Colors.grey[600], size: 20),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF14141E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              if (widget.group != null) {
                                controller.editGroup(widget.group!.id);
                              } else {
                                controller.createGroup();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5A4181), // Muted purple outline style from image
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Obx(() => controller.isLoading.value 
                                ? const SizedBox(
                                    width: 18, 
                                    height: 18, 
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF9074B6))
                                  )
                                : Row(
                                    children: [
                                      const Icon(Icons.save_outlined, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.group != null ? 'Update Group' : 'Create Group',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
