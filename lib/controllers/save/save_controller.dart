// controllers/save_controller.dart
import 'dart:io';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/models/save_card_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';
import 'package:share_plus/share_plus.dart';

class SaveController extends GetxController {

  // Observable variables
  final RxList<SavedCardModel> savedCards = <SavedCardModel>[].obs;
  final RxList<SavedCardModel> filteredCards = <SavedCardModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString sortBy = 'date'.obs; // date, name, company
  final RxString searchQuery = ''.obs;
  final RxSet<String> selectedCards = <String>{}.obs;
  final RxBool isSelectionMode = false.obs;
  final RxList<CardModel> allCardDetails = <CardModel>[].obs;
  final RxMap<String, CardModel> cardDetailsMap = <String, CardModel>{}.obs;


  @override
  void onInit() {
    super.onInit();
    fetchSavedCards();

    // Auto-filter when search query changes
    // ever(searchQuery, (_) => filterCards());
    // // Auto-sort when sort option changes
    // ever(sortBy, (_) => sortCards());
  }

  void dispose(){
    super.dispose();
  }

  // 1. FETCH SAVED CARDS FROM API
  Future<void> fetchSavedCards() async {
    try {
      isLoading.value = true;

      final  response = await dioClient.get(ApiEndpoints.savedCard);

      if (response.statusCode == 200) {
        final data = response.data;

        final List list = data['savedCards'] ?? [];

        final cards = list
            .map((e) => SavedCardModel.fromJson(e))
            .toList();

        print("Saved Cards:${cards.length}");
        savedCards.value = cards;
        filteredCards.value = cards;
        await fetchAllCardDetails(cards);
        sortCards(); // your existing logic
        update();
      }
    } catch (e) {
      CommonSnackbar.error('Failed to load saved cards');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllCardDetails(List<SavedCardModel> savedCards) async {
    try {
      // Extract unique card IDs
      final cardIds = savedCards
          .map((savedCard) => savedCard.card.shortUrl)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      print("Fetching details for ${cardIds.length} cards");

      // Fetch all card details in parallel
      final results = await Future.wait(
        cardIds.map((cardId) => getCardDetailsById(cardId)),
      );

      // Store in map for quick lookup
      cardDetailsMap.clear();
      for (var cardDetail in results) {
        if (cardDetail != null) {
          cardDetailsMap[cardDetail.id] = cardDetail;
        }
      }

      // Also store in list
      allCardDetails.value = results.whereType<CardModel>().toList();
      print("Success:${allCardDetails.length}");

      print("Fetched ${allCardDetails.length} card details");
    } catch (e) {
      print("Error fetching all card details: $e");
    }
  }

  Future<CardModel?> getCardDetailsById(String cardId) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.viewPublicCard(cardId),
      );

      if (response.statusCode == 200) {
        final cardJson = response.data['card'];
        return CardModel.fromJson(cardJson);
      }
      return null;
    } catch (e, t) {
      print("Error fetching card details for $cardId: $e $t");
      return null;
    }
  }


  // 2. REFRESH CARDS (Pull to refresh)
  Future<void> refreshSavedCards() async {
    try {
      isRefreshing.value = true;
      await fetchSavedCards();
    } finally {
      isRefreshing.value = false;
    }
  }

  // 3. SEARCH CARDS
  void filterCards() {
    if (searchQuery.value.isEmpty) {
      filteredCards.value = savedCards;
    } else {
      filteredCards.value = savedCards.where((card) {
        final query = searchQuery.value.toLowerCase();
        return card.card.name.toLowerCase().contains(query) ||
            card.card.company.toLowerCase().contains(query) ;
      }).toList();
    }
    sortCards();
  }

  // 4. SORT CARDS
  void sortCards() {
    print("DUmmy");
    switch (sortBy.value) {
      case 'date':
        filteredCards.sort((a, b) => b.savedAt.compareTo(a.savedAt));
        break;
      case 'name':
        filteredCards.sort((a, b) => a.card.name.compareTo(b.card.name));
        break;
      case 'company':
        filteredCards.sort((a, b) => a.card.company.compareTo(b.card.company));
        break;
    }
    update();
  }

  // 5. CHANGE SORT OPTION
  void changeSortBy(String sortOption) {
    sortBy.value = sortOption;
    sortCards();
  }

  // 6. UPDATE SEARCH QUERY
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // 7. TOGGLE FAVORITE
  Future<void> toggleFavorite(String cardId,bool favorite) async {
    try {
      final response = await dioClient.patch(
        ApiEndpoints.toggleSavedCardFavorite(cardId),
        data: {'isFavorite': !favorite}
      );

      print("Responnse Status Code:$favorite ${response.statusCode} ${response.data}");

      // Update local state only if API succeeds
      // final index = savedCards.indexWhere((card) => card.id == cardId);
      // if (index != -1) {
      //   savedCards[index] = savedCards[index].copyWith(
      //     isFavorite: !savedCards[index].isFavorite,
      //   );
      //   filterCards();
      // }
      await fetchSavedCards();
      CommonSnackbar.success('Favorite updated');
    } catch (e) {
      CommonSnackbar.error('Failed to update favorite');
    }
  }

  Future<void> deleteCard(String cardId) async {
    print("Card ID:$cardId");
    final response = await dioClient.delete(
      ApiEndpoints.deleteSavedCard(cardId),
    );
    if(response.statusCode == 200){
    CommonSnackbar.success('Deleted Saved Card updated');
    await fetchSavedCards();
  }
  else{
    CommonSnackbar.error('Failed to delete saved card');
  }
}


  // 8. REMOVE CARD
  Future<void> removeCard(String cardId) async {
    try {
      // final success = await _repository.unsaveCard(cardId);
      // if (success) {
      //   savedCards.removeWhere((card) => card.id == cardId);
      //   filteredCards.removeWhere((card) => card.id == cardId);
      // }
    } catch (e) {
      CommonSnackbar.error('Failed to remove card');
    }
  }

  // 9. SELECTION MODE FUNCTIONS
  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedCards.clear();
    }
  }

  void toggleCardSelection(String cardId) {
    print("Upd");
    if (selectedCards.contains(cardId)) {
      selectedCards.remove(cardId);
    } else {
      selectedCards.add(cardId);
    }
    update();
  }

  bool isCardSelected(String cardId) {
    print("Card ID:$cardId");
    print("SelectedCard:$selectedCards");
    return selectedCards.contains(cardId);

  }

  void selectAllCards() {
    selectedCards.clear();
    selectedCards.addAll(filteredCards.map((card) => card.id));
  }

  void deselectAllCards() {
    selectedCards.clear();
  }

  // 10. DELETE SELECTED CARDS (BULK DELETE)
  Future<void> deleteSelectedCards() async {
    if (selectedCards.isEmpty) return;

    try {
      final cardsToDelete = selectedCards.toList();

      for (final cardId in cardsToDelete) {
        await dioClient.delete(
          ApiEndpoints.deleteSavedCard(cardId),
        );
      }

      // Update local state after successful deletes
      savedCards.removeWhere((card) => cardsToDelete.contains(card.id));
      filteredCards.removeWhere((card) => cardsToDelete.contains(card.id));
      selectedCards.clear();
      isSelectionMode.value = false;
      CommonSnackbar.success('${cardsToDelete.length} card(s) deleted');
    } catch (e) {
      CommonSnackbar.error('Failed to delete selected cards');
    }
  }



  // 12. DOWNLOAD CARD
  // void downloadCard(SavedCardModel card) {
  //   // Implement your download functionality here
  //   CommonSnackbar.success('Downloading ${card.card.name}\'s card');
  // }

  Future<void> downloadCard({
    required CardModel card,

  }) async {
    // Ask permission
    final permission = await Permission.contacts.request();
    if (!permission.isGranted) {
      throw Exception('Contacts permission denied');
    }

    final contact = Contact(
      name: Name(first: card.name),
      phones: card.contact.phone != null && (card.contact.phone?.isNotEmpty ?? false)
          ? [Phone(card.contact.phone ?? '')]
          : [],
      emails: card.contact.email != null && (card.contact.email?.isNotEmpty ?? false)
          ? [Email(card.contact.email ?? '')]
          : [],
      organizations: card.company != null && card.company.isNotEmpty
          ? [
        Organization(
          company: card.company,
          title: card.title ?? '',
        )
      ]
          : [],
      // websites: card.contact. != null && card.website.isNotEmpty
      //     ? [Website(card.website)]
      //     : [],
    );

    // 🔑 This opens the SYSTEM contact editor
    await FlutterContacts.openExternalInsert(contact);
  }


  String generateVcf(CardModel card) {
    return '''
BEGIN:VCARD
VERSION:3.0
FN:${card.name}
N:${card.name};;;;
ORG:${card.company ?? ''}
TITLE:${card.title ?? ''}
TEL;TYPE=CELL:${card.contact.phone ?? ''}
EMAIL:${card.contact.email ?? ''}
END:VCARD
'''.trim();
  }

  Future<void> shareCard(CardModel card) async {
    final vcfContent = generateVcf(card);

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/${card.name}.vcf';

    final file = File(filePath);
    await file.writeAsString(vcfContent);

    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Contact details for ${card.name}',
    );
  }

  CardModel? getCardModelFromSaved(SavedCardModel savedCard) {
    return cardDetailsMap[savedCard.card.id];
  }

  // In SaveController
  // In SaveController
  Future<void> exportSelectedCards() async {
    try {
      if (selectedCards.isEmpty) {
        CommonSnackbar.error('No cards selected');
        return;
      }

      isLoading.value = true;

      // Get all selected cards' full details
      final cardsToExport = <CardModel>[];

      for (final cardId in selectedCards) {
        final savedCard = savedCards.firstWhereOrNull((card) => card.id == cardId);
        if (savedCard != null) {
          final cardModel = getCardModelFromSaved(savedCard);
          if (cardModel != null) {
            cardsToExport.add(cardModel);
          }
        }
      }

      if (cardsToExport.isEmpty) {
        CommonSnackbar.error('No card details available');
        return;
      }

      // Download each card
      for (final card in cardsToExport) {
        await downloadCard(card: card);
        await Future.delayed(Duration(milliseconds: 500)); // Small delay between downloads
      }

      CommonSnackbar.success('Exported ${cardsToExport.length} contact(s)');

      // Clear selection after export
      deselectAllCards();
      toggleSelectionMode();

    } catch (e) {
      CommonSnackbar.error('Failed to export contacts');
    } finally {
      isLoading.value = false;
    }
  }

  // GETTERS
  int get cardCount => filteredCards.length;
  int get selectedCount => selectedCards.length;
}