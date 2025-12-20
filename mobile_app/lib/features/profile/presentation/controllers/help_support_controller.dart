import 'package:get/get.dart';

/// FAQ Item Model
class FAQItem {
  final int id;
  final String question;
  final String answer;
  final String category;
  final String? actionLink;
  final String? actionText;

  FAQItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.actionLink,
    this.actionText,
  });
}

/// Help & Support Controller
class HelpSupportController extends GetxController {
  // Search query
  final RxString searchQuery = ''.obs;

  // Selected category
  final RxString selectedCategory = 'Voting'.obs;

  // Expanded FAQ items - default to first item expanded
  final RxSet<int> expandedItems = <int>{1}.obs;

  // FAQ Categories
  final List<String> categories = ['Voting', 'Account', 'Technical', 'General'];

  // FAQ Data - mapped from client FAQ page
  final List<FAQItem> allFAQs = [
    // Voting category
    FAQItem(
      id: 1,
      question: 'Where is my polling station?',
      answer:
          'Polling stations are located in the Student Union building, Room 104. You can also cast your vote digitally through this app if you are registered for remote voting.',
      category: 'Voting',
      actionLink: '', // Can add map link later
      actionText: 'View on Map',
    ),
    FAQItem(
      id: 2,
      question: 'How does ranked-choice voting work?',
      answer:
          'Ranked-choice voting allows you to rank candidates in order of preference (1st choice, 2nd choice, 3rd choice, etc.). If no candidate receives a majority of first-choice votes, the candidate with the fewest votes is eliminated, and their votes are redistributed to the remaining candidates based on voters\' next choices. This process continues until a candidate receives a majority. Our platform provides clear instructions when you\'re voting.',
      category: 'Voting',
    ),
    FAQItem(
      id: 3,
      question: 'Can I change my vote?',
      answer:
          'No, votes cannot be changed once submitted. This ensures election integrity and prevents manipulation. Please review your selections carefully before confirming your vote. If you make a mistake before submitting, you can go back and change your selections. Once you click \'Submit Vote\' and confirm, your vote is final and encrypted.',
      category: 'Voting',
    ),
    FAQItem(
      id: 4,
      question: 'How long do I have to vote?',
      answer:
          'Voting periods vary by election. Each election announcement clearly states the start and end times. Typically, elections are open for 24-72 hours. You\'ll receive notifications about upcoming elections and reminders as the deadline approaches. Make sure to vote before the election closes, as late votes cannot be accepted.',
      category: 'Voting',
    ),
    FAQItem(
      id: 5,
      question: 'When do polls close?',
      answer:
          'Poll closing times are specified in each election announcement. Typically, polls close at midnight on the final day of voting, but this can vary. You\'ll receive reminders as the deadline approaches. Make sure to vote before the election closes, as late votes cannot be accepted.',
      category: 'Voting',
    ),
    FAQItem(
      id: 6,
      question: 'Are write-in candidates allowed?',
      answer:
          'This depends on the specific election rules. Some elections allow write-in candidates, while others only allow voting for pre-approved candidates. The election announcement will clearly indicate whether write-ins are permitted. If allowed, you\'ll see a \'Write-in Candidate\' option when voting.',
      category: 'Voting',
    ),
    // Account category
    FAQItem(
      id: 7,
      question: 'How do I reset my password?',
      answer:
          'If you forget your password, click \'Forgot Password\' on the login page. Enter your registered email address, and we\'ll send you a secure password reset link. Make sure to check your spam folder if you don\'t see the email. The reset link will expire after 24 hours for security purposes.',
      category: 'Account',
    ),
    FAQItem(
      id: 8,
      question: 'How do I update my profile information?',
      answer:
          'You can update your profile information by logging in and navigating to \'Settings\' in your dashboard. From there, you can update your profile photo, change your password, and manage your account preferences. Some information (like your email) may require verification before changes take effect.',
      category: 'Account',
    ),
    FAQItem(
      id: 9,
      question: 'How do I register to vote in campus elections?',
      answer:
          'To participate in campus elections, you need to be a registered student at Fisk University with a verified email address. Simply log in to the platform using your university email credentials. If you haven\'t created an account yet, click \'Register\' and follow the verification process. Once your email is verified, you\'ll be eligible to vote in all elections you\'re qualified for.',
      category: 'Account',
    ),
    // Technical category
    FAQItem(
      id: 10,
      question: 'What if I experience technical issues while voting?',
      answer:
          'If you encounter any technical issues, first try refreshing the page or clearing your browser cache. If the problem persists, contact our support team immediately at elections@fisk.edu or use the support chat feature. We provide 24/7 support during active election periods to ensure everyone can vote successfully.',
      category: 'Technical',
    ),
    FAQItem(
      id: 11,
      question: 'Can I vote on my mobile device?',
      answer:
          'Absolutely! Our platform is fully responsive and works seamlessly on smartphones, tablets, and desktop computers. You can vote from any device with internet access. We recommend using a stable internet connection to ensure your vote is submitted successfully.',
      category: 'Technical',
    ),
    // General category
    FAQItem(
      id: 12,
      question: 'What types of elections can I vote in?',
      answer:
          'You can vote in any election you\'re eligible for based on your student status, class year, major, or organization membership. This includes Student Government elections, Class Representative positions, Residence Hall elections, Club Officer elections, and Department-specific elections. Each election will show your eligibility status before voting begins.',
      category: 'General',
    ),
    FAQItem(
      id: 13,
      question: 'How secure is my vote?',
      answer:
          'Your vote is protected by end-to-end encryption and industry-standard security measures. We use secure authentication, encrypted data transmission, and maintain complete audit trails. Your personal voting choices are never linked to your identity in our system, ensuring complete anonymity while maintaining election integrity. All security measures are regularly audited by independent security experts.',
      category: 'General',
    ),
    FAQItem(
      id: 14,
      question: 'Who can see how I voted?',
      answer:
          'No one can see how you voted. The voting system is designed to ensure complete anonymity. While we maintain audit logs for election integrity, these logs never link your identity to your voting choices. Election administrators can only see aggregate vote counts and results, never individual voting patterns.',
      category: 'General',
    ),
    FAQItem(
      id: 15,
      question: 'When are election results announced?',
      answer:
          'Election results are typically announced immediately after the voting period ends. For most elections, results are available in real-time on the Results page. Some elections may have a brief processing period to ensure accuracy, but results are usually published within minutes of the election closing.',
      category: 'General',
    ),
    FAQItem(
      id: 16,
      question: 'Can I see detailed election results?',
      answer:
          'Yes! Once results are published, you can view comprehensive election statistics including vote counts, percentages, and breakdowns by position. For ranked-choice elections, you can see round-by-round results showing how votes were redistributed. All results are transparent and available to all students.',
      category: 'General',
    ),
  ];

  /// Get filtered FAQs based on search and category
  List<FAQItem> get filteredFAQs {
    return allFAQs.where((faq) {
      final matchesCategory =
          selectedCategory.value == 'All' ||
          faq.category == selectedCategory.value;
      final matchesSearch =
          searchQuery.value.isEmpty ||
          faq.question.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          faq.answer.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Toggle FAQ item expansion
  void toggleFAQ(int id) {
    if (expandedItems.contains(id)) {
      expandedItems.remove(id);
    } else {
      expandedItems.add(id);
    }
  }

  /// Check if FAQ item is expanded
  bool isExpanded(int id) {
    return expandedItems.contains(id);
  }

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Set selected category
  void setCategory(String category) {
    selectedCategory.value = category;
  }
}
