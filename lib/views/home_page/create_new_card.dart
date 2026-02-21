import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/common/common_textfield.dart';
import 'package:rolo_digi_card/common/custom_textfield.dart';
import 'package:rolo_digi_card/controllers/home/home_page_controller.dart';
import 'package:rolo_digi_card/controllers/organization/card_management_controller.dart';
import 'package:rolo_digi_card/models/card_model.dart';
// Assuming AppColors is available and contains the necessary colors
// like AppColors.gradientStart, AppColors.textPrimary, etc.
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/home_page/home_page.dart';
import 'package:rolo_digi_card/views/my_cards_page/widget/business_card_details.dart';

// --- Helper Widgets and Constants ---

// This new widget will be used to create the distinct, card-like sections
class _CardSection extends StatelessWidget {
  final String title;
  final Widget content;
  final IconData icon;

  const _CardSection({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gradientStart.withOpacity(
          0.9,
        ), // Slightly different background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.progressPink,
                size: 20,
              ), // Using AppColors.progressPink for the icon color
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            color: AppColors.textPrimary.withOpacity(0.10), // line color
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }
}

// --- CreateNewCard State/Widget ---

class CreateNewCard extends StatefulWidget {
  const CreateNewCard({super.key});

  @override
  State<CreateNewCard> createState() => _CreateNewCardState();
}

class _CreateNewCardState extends State<CreateNewCard> {
  final homePageController = Get.find<HomePageController>();
  // Removed multi-step logic variables
  String selectedTheme = 'Light';
  bool isPublicCard = true;
  bool isMinimalView = false; // New state for the minimal switch in the AppBar
  List<String> skills = [];
  bool isEditMode = false;
  bool isOrganization = false;
  CardModel? editingCard;

  void initState() {
    homePageController.showSuccess.value = false;
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      isEditMode = args['isEdit'] ?? false;
      isOrganization = args['isOrganization'] ?? false;
      editingCard = args['card'] as CardModel?;

      if (isEditMode && editingCard != null) {
        _populateFieldsForEdit();
      }
    } else {
      homePageController.resetForm();
    }
  }

  // ✨ COMPLETELY NEW METHOD
  void _populateFieldsForEdit() {
    print("Card ID:${editingCard?.id}");
    if (editingCard == null) return;

    // Populate all text controllers with existing card data
    homePageController.nameController.text = editingCard!.name;
    homePageController.designationController.text = editingCard!.title;
    homePageController.companyController.text = editingCard!.company ?? '';
    homePageController.phoneController.text = editingCard!.contact.phone ?? '';
    homePageController.emailController.text = editingCard!.contact.email ?? '';
    homePageController.websiteController.text = editingCard!.website ?? '';

    // New Fields
    homePageController.personalEmailController.text =
        editingCard!.contact.personalEmail ?? '';
    homePageController.personalPhoneController.text =
        editingCard!.contact.personalPhone ?? '';

    if (editingCard!.address != null) {
      homePageController.addressLine1Controller.text =
          editingCard!.address!.addressLine1 ?? '';
      homePageController.addressLine2Controller.text =
          editingCard!.address!.addressLine2 ?? '';
      homePageController.cityController.text = editingCard!.address!.city ?? '';
      homePageController.stateController.text =
          editingCard!.address!.state ?? '';
      homePageController.countryController.text =
          editingCard!.address!.country ?? '';
      homePageController.zipController.text =
          editingCard!.address!.zipCode ?? '';
    }

    homePageController.industryController.text = editingCard!.industry ?? '';
    // homePageController.departmentController.text = editingCard!.department ?? '';
    homePageController.bioController.text = editingCard!.bio ?? '';

    // Socials
    homePageController.linkedinController.text = editingCard!.linkedinUrl ?? '';
    homePageController.twitterController.text = editingCard!.twitterUrl ?? '';
    homePageController.instagramController.text =
        editingCard!.instagramUrl ?? '';
    homePageController.githubController.text = editingCard!.githubUrl ?? '';
    homePageController.facebookController.text = editingCard!.facebookUrl ?? '';
    homePageController.youtubeController.text = editingCard!.youtubeUrl ?? '';

    // Set theme
    homePageController.selectedTheme.value =
        editingCard!.theme.cardStyle.capitalize ?? 'Light';

    // Set public/private
    homePageController.isPublicCard.value = editingCard!.isPublic;

    // Set skills/tags
    if (editingCard!.tags.isNotEmpty) {
      homePageController.skills.value = editingCard!.tags.toList();
    }
  }

  void addSkill(HomePageController controller) {
    if (controller.skillController.text.isNotEmpty) {
      setState(() {
        skills.add(controller.skillController.text);
        controller.skillController.clear();
      });
    }
  }

  Widget _buildProfilePictureSection(HomePageController controller) {
    return _CardSection(
      icon: Icons.camera_alt_outlined,
      title: 'Profile Picture',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.gradientStart,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  image: controller.profileImage != null
                      ? DecorationImage(
                          image: FileImage(controller.profileImage!),
                          fit: BoxFit.cover,
                        )
                      // If no local image, check if we're editing and have a profile URL
                      : (isEditMode &&
                            editingCard?.profile != null &&
                            editingCard!.profile!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(
                            editingCard!.profile!,
                          ), // You might want to use a cached network image
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    controller.profileImage == null &&
                        (!isEditMode || editingCard?.profile == null)
                    ? Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () => controller.pickImage(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.progressPink,
                    ),
                    child: Text(
                      "Choose File",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  if (controller.profileImage != null)
                    TextButton(
                      onPressed: () => controller.removeImage(),
                      child: Text(
                        "Remove",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  else
                    Text(
                      "No file chosen",
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "(Optional)",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInformationSection(HomePageController controller) {
    return _CardSection(
      icon: Icons.person_outline,
      title: 'Basic Information',
      content: Column(
        children: [
          CustomFormTextField(
            isImportant: true,
            title: 'Full Name',
            hintText: 'Enter your name',
            controller: controller.nameController,
          ),
          const SizedBox(height: 20),
          CustomFormTextField(
            isImportant: true,
            title: 'Designation',
            hintText: 'Enter your designation',
            controller: controller.designationController,
          ),
          const SizedBox(height: 20),
          CustomFormTextField(
            isImportant: true,
            title: 'Company',
            hintText: 'Enter your company',
            controller: controller.companyController,
          ),
          const SizedBox(height: 20),
          CustomFormTextField(
            isImportant: true,
            title: 'Phone Number',
            hintText: 'Enter your phone number',
            controller: controller.phoneController,
          ),
          const SizedBox(height: 20),
          CustomFormTextField(
            isImportant: true,
            title: 'Email',
            hintText: 'Enter your email',
            controller: controller.emailController,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(HomePageController controller) {
    return _CardSection(
      icon: Icons.call_outlined,
      title: 'Contact',
      content: Column(
        children: [
          CustomFormTextField(
            title: 'Website',
            hintText: 'Enter your website',
            controller: controller.websiteController,
          ),
          const SizedBox(height: 20),
          // Email Addresses
          Text(
            "Email Addresses",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          CustomFormTextField(
            isImportant: true,
            title: 'Work Email',
            hintText: 'john@company.com',
            controller: controller.emailController,
          ),
          const SizedBox(height: 10),
          CustomFormTextField(
            title: 'Personal Email',
            hintText: 'john@gmail.com',
            controller: controller.personalEmailController,
          ),
          const SizedBox(height: 20),
          // Phone Numbers
          Text(
            "Phone Numbers",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          CustomFormTextField(
            isImportant: true,
            title: 'Work Phone',
            hintText: '+1 ...',
            controller: controller.phoneController,
          ),
          const SizedBox(height: 10),
          CustomFormTextField(
            title: 'Personal Phone',
            hintText: '+1 ...',
            controller: controller.personalPhoneController,
          ),

          const SizedBox(height: 20),
          // Location
          Text(
            "Location",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomFormTextField(
                  title: 'Address Line 1',
                  hintText: '123 Main St',
                  controller: controller.addressLine1Controller,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomFormTextField(
                  title: 'Address Line 2',
                  hintText: 'Apt, Suite',
                  controller: controller.addressLine2Controller,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomFormTextField(
                  title: 'City',
                  hintText: 'San Francisco',
                  controller: controller.cityController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomFormTextField(
                  title: 'State/Province',
                  hintText: 'California',
                  controller: controller.stateController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomFormTextField(
                  title: 'Country',
                  hintText: 'United States',
                  controller: controller.countryController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomFormTextField(
                  title: 'Zip Code',
                  hintText: '12345',
                  controller: controller.zipController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalSection(HomePageController controller) {
    return _CardSection(
      icon: Icons.business_center_outlined,
      title: 'Professional',
      content: Column(
        children: [
          CustomFormTextField(
            title: 'Industry',
            hintText: 'Enter your industry',
            controller: controller.industryController,
          ),
          const SizedBox(height: 20),
          CustomFormTextField(
            title: 'Department',
            hintText: 'Enter your department',
            controller: controller.departmentController,
          ),
          const SizedBox(height: 20),
          CustomFormTextField(
            title: 'Bio',
            hintText: 'Enter your bio',
            controller: controller.bioController,
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skills',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // TextField (flexible)
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.gradientStart,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.10),
                        ),
                      ),
                      child: TextFormField(
                        controller: controller.skillController,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Add a skill',
                          hintStyle: const TextStyle(
                            color: AppColors.qrText,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Add Button
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF6339A), Color(0xFF9810FA)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        controller.addSkill();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (controller.skills.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.skills.map((skill) {
                    return Chip(
                      label: Text(
                        skill,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      deleteIcon: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                      onDeleted: () {
                        setState(() {
                          controller.skills.remove(skill);
                        });
                      },
                      backgroundColor: AppColors.progressPink,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinksSection(HomePageController controller) {
    return _CardSection(
      icon: Icons.link_outlined,
      title: 'Social Links',
      content: Column(
        children: [
          CustomFormTextField(
            title: 'LinkedIn',
            hintText: 'linkedin.com/in/username',
            controller: controller.linkedinController,
          ),
          const SizedBox(height: 20),
          CustomFormTextField(
            title: 'Twitter',
            hintText: '@username',
            controller: controller.twitterController,
          ),
          const SizedBox(height: 20),
          CustomFormTextField(
            title: 'Instagram',
            hintText: '@username',
            controller: controller.instagramController,
          ),
          const SizedBox(height: 20),
          CustomFormTextField(
            title: 'GitHub',
            hintText: 'github.com/username',
            controller: controller.githubController,
          ),
          const SizedBox(height: 20),
          CustomFormTextField(
            title: 'YouTube',
            hintText: 'youtube.com/@channel',
            controller: controller.youtubeController,
          ),
          const SizedBox(height: 20),
          CustomFormTextField(
            title: 'Facebook',
            hintText: 'facebook.com/username',
            controller: controller.facebookController,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    HomePageController controller,
    String theme,
    String description,
  ) {
    bool isSelected = controller.selectedTheme.value == theme;
    return GestureDetector(
      onTap: () {
        setState(() {
          controller.selectedTheme.value = theme;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gradientStart.withOpacity(0.50),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.selectedBorder
                : AppColors.textPrimary.withOpacity(0.10), // Highlight color
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.selectedBorder, // Pink
                      AppColors.switchBlue, // Blue
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white, // White checkmark
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizeYourCardSection(HomePageController controller) {
    return _CardSection(
      icon: Icons.color_lens_outlined,
      title: 'Customize Your Card',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Theme',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildThemeOption(controller, 'Light', 'Clean and professional'),
          const SizedBox(height: 12),
          _buildThemeOption(controller, 'Dark', 'Modern and sleek'),
          const SizedBox(height: 12),
          _buildThemeOption(
            controller,
            'Glassmorphic',
            'Elegant with blur effects',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Using a small filled circle for the bullet point
          Container(
            margin: const EdgeInsets.only(top: 5, right: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardVisibilitySection(HomePageController controller) {
    return _CardSection(
      icon: Icons.visibility_outlined,
      title: 'Card Visibility',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gradientStart.withOpacity(0.50),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.textPrimary.withOpacity(
                  0.10,
                ), // Highlight color
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Public Card',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Allow anyone with the link to view your card',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    value: controller.isPublicCard.value,
                    onChanged: (value) {
                      setState(() {
                        controller.isPublicCard.value = value;
                      });
                    },
                    activeColor:
                        AppColors.progressPink, // Active color for the switch
                    inactiveThumbColor: Colors.grey.shade600,
                    inactiveTrackColor: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.progressPink, size: 20),
              const SizedBox(width: 8),
              Text(
                'Public Card Benefits',
                style: TextStyle(
                  color: AppColors.textGrayPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBenefit('Share your card with anyone via QR code or link'),
          _buildBenefit('Others can save your contact information'),
          _buildBenefit('Track views and analytics'),
          _buildBenefit('Perfect for networking and business purposes'),
        ],
      ),
    );
  }

  // Kept the original success screen logic for completeness, though it's not the primary change area
  Widget buildSuccessScreen(HomePageController controller) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
        height: MediaQuery.of(context).size.height * 0.70,
        width: MediaQuery.of(context).size.width * 0.90,

        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  child: Image.asset('assets/create_page/verified.png'),
                ),
                const SizedBox(height: 32),
                Text(
                  controller.nameController.text,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  controller.designationController.text,
                  style: TextStyle(
                    color: AppColors.lightlightText,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isEditMode
                      ? 'Card updated\nsuccessfully.'
                      : 'Card creation\nsuccessful.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          AppColors.selectedBorder, // pink
                          AppColors.switchBlue, // amber
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(Rect.fromLTWH(0, 0, 400, 70)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isEditMode
                      ? 'Your card has been successfully\nupdated in your My Cards section.'
                      : 'Your card has been successfully\nadded to your My Cards section.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.selectedBorder, // pink
                            AppColors.switchBlue, // amber
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(
                        2,
                      ), // this becomes the border thickness
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors
                              .black, // background of button (can be transparent)
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: OutlinedButton(
                          onPressed: () {
                            Get.offAllNamed("/sidebar");
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide.none, // disable default border
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          child: const Text(
                            'GO TO HOME',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.selectedBorder, // pink
                            AppColors.switchBlue, // amber
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (controller.shortUrl != null) {
                            // Get.to(
                            //   () => BusinessCardProfilePage(
                            //     // cardId: controller.shortUrl ?? '',
                            //   ),
                            // );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'VIEW CARD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () {
                  // Add your close action here
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close, color: AppColors.textPrimary, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The background color of the scaffold should be the dark background
      backgroundColor: Colors.black,
      appBar: AppBar(
        // Transparent AppBar to blend with the background
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading:
            false, // Don't show the back button by default
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isEditMode ? 'Edit Card' : 'Create New Card',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Row(
            children: [
              Text(
                'Minimal',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isMinimalView,
                  onChanged: (value) {
                    setState(() {
                      isMinimalView = value;
                    });
                  },
                  activeColor: AppColors.textPrimary,
                  inactiveThumbColor: Colors.grey.shade600,
                  inactiveTrackColor: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: GetBuilder<HomePageController>(
        builder: (controller) {
          return SafeArea(
            child: controller.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : controller.showSuccess.value
                ? buildSuccessScreen(controller)
                : SingleChildScrollView(
                    // Wrap the main content in a SingleChildScrollView
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // All form sections are now built sequentially
                          _buildProfilePictureSection(controller),
                          _buildBasicInformationSection(controller),
                          Visibility(
                            visible: !isMinimalView,
                            child: _buildContactSection(controller),
                          ),
                          Visibility(
                            visible: !isMinimalView,
                            child: _buildProfessionalSection(controller),
                          ),
                          Visibility(
                            visible: !isMinimalView,
                            child: _buildSocialLinksSection(controller),
                          ),
                          Visibility(
                            visible: !isMinimalView,
                            child: _buildCustomizeYourCardSection(controller),
                          ),
                          Visibility(
                            visible: !isMinimalView,
                            child: _buildCardVisibilitySection(controller),
                          ),

                          // Single Save Card button at the bottom
                          Container(
                            width: double.infinity,
                            height: 36,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.progressPink,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (isOrganization) {
                                  final orgController =
                                      Get.isRegistered<
                                        CardManagementController
                                      >()
                                      ? Get.find<CardManagementController>()
                                      : Get.put(CardManagementController());
                                  final cardDataMap = controller
                                      .buildCardDataMap(
                                        controller.getThemeColors(),
                                      );
                                  if (isEditMode) {
                                    orgController.updateOrgCard(
                                      editingCard!.id,
                                      cardDataMap,
                                    );
                                  } else {
                                    orgController.createOrgCard(cardDataMap);
                                  }
                                } else {
                                  if (isEditMode) {
                                    controller.updateCard(editingCard!.id);
                                  } else {
                                    controller.createCard();
                                  }
                                }
                              },
                              icon: Icon(
                                Icons.check,
                                color: AppColors.buttonBlack,
                                size: 20,
                              ),
                              label: Text(
                                'Save Card',
                                style: TextStyle(
                                  color: AppColors.buttonBlack,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
