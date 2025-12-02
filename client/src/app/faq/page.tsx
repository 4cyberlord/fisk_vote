"use client";

import { useState } from "react";
import {
  Search,
  ChevronDown,
  HelpCircle,
  Shield,
  Vote,
  User,
  Clock,
  Lock,
  FileText,
  Mail,
  MessageCircle,
} from "lucide-react";
import { PublicHeader } from "@/components/layout/PublicHeader";
import { PublicFooter } from "@/components/layout/PublicFooter";
import { Button } from "@/components";
import Link from "next/link";

interface FAQItem {
  id: number;
  question: string;
  answer: string;
  category: string;
  icon: typeof HelpCircle;
}

const faqCategories = [
  { id: "all", name: "All Questions", icon: HelpCircle },
  { id: "getting-started", name: "Getting Started", icon: User },
  { id: "voting", name: "Voting", icon: Vote },
  { id: "security", name: "Security", icon: Shield },
  { id: "account", name: "Account", icon: Lock },
  { id: "results", name: "Results", icon: FileText },
];

const faqData: FAQItem[] = [
  {
    id: 1,
    question: "How do I register to vote in campus elections?",
    answer:
      "To participate in campus elections, you need to be a registered student at Fisk University with a verified email address. Simply log in to the platform using your university email credentials. If you haven't created an account yet, click 'Register' and follow the verification process. Once your email is verified, you'll be eligible to vote in all elections you're qualified for.",
    category: "getting-started",
    icon: User,
  },
  {
    id: 2,
    question: "What types of elections can I vote in?",
    answer:
      "You can vote in any election you're eligible for based on your student status, class year, major, or organization membership. This includes Student Government elections, Class Representative positions, Residence Hall elections, Club Officer elections, and Department-specific elections. Each election will show your eligibility status before voting begins.",
    category: "getting-started",
    icon: Vote,
  },
  {
    id: 3,
    question: "How does ranked-choice voting work?",
    answer:
      "Ranked-choice voting allows you to rank candidates in order of preference (1st choice, 2nd choice, 3rd choice, etc.). If no candidate receives a majority of first-choice votes, the candidate with the fewest votes is eliminated, and their votes are redistributed to the remaining candidates based on voters' next choices. This process continues until a candidate receives a majority. Our platform provides clear instructions when you're voting.",
    category: "voting",
    icon: Vote,
  },
  {
    id: 4,
    question: "Can I change my vote after submitting it?",
    answer:
      "No, votes cannot be changed once submitted. This ensures election integrity and prevents manipulation. Please review your selections carefully before confirming your vote. If you make a mistake before submitting, you can go back and change your selections. Once you click 'Submit Vote' and confirm, your vote is final and encrypted.",
    category: "voting",
    icon: Lock,
  },
  {
    id: 5,
    question: "How secure is my vote?",
    answer:
      "Your vote is protected by end-to-end encryption and industry-standard security measures. We use secure authentication, encrypted data transmission, and maintain complete audit trails. Your personal voting choices are never linked to your identity in our system, ensuring complete anonymity while maintaining election integrity. All security measures are regularly audited by independent security experts.",
    category: "security",
    icon: Shield,
  },
  {
    id: 6,
    question: "Who can see how I voted?",
    answer:
      "No one can see how you voted. The voting system is designed to ensure complete anonymity. While we maintain audit logs for election integrity, these logs never link your identity to your voting choices. Election administrators can only see aggregate vote counts and results, never individual voting patterns.",
    category: "security",
    icon: Shield,
  },
  {
    id: 7,
    question: "What if I forget my password?",
    answer:
      "If you forget your password, click 'Forgot Password' on the login page. Enter your registered email address, and we'll send you a secure password reset link. Make sure to check your spam folder if you don't see the email. The reset link will expire after 24 hours for security purposes.",
    category: "account",
    icon: Lock,
  },
  {
    id: 8,
    question: "How do I update my profile information?",
    answer:
      "You can update your profile information by logging in and navigating to 'Settings' in your dashboard. From there, you can update your profile photo, change your password, and manage your account preferences. Some information (like your email) may require verification before changes take effect.",
    category: "account",
    icon: User,
  },
  {
    id: 9,
    question: "When are election results announced?",
    answer:
      "Election results are typically announced immediately after the voting period ends. For most elections, results are available in real-time on the Results page. Some elections may have a brief processing period to ensure accuracy, but results are usually published within minutes of the election closing.",
    category: "results",
    icon: FileText,
  },
  {
    id: 10,
    question: "Can I see detailed election results?",
    answer:
      "Yes! Once results are published, you can view comprehensive election statistics including vote counts, percentages, and breakdowns by position. For ranked-choice elections, you can see round-by-round results showing how votes were redistributed. All results are transparent and available to all students.",
    category: "results",
    icon: FileText,
  },
  {
    id: 11,
    question: "What happens if there's a tie in an election?",
    answer:
      "In the event of a tie, the election rules specify the tie-breaking procedure. This is typically outlined in the election announcement. Common methods include a runoff election, coin flip, or other predetermined methods. The specific procedure will be clearly communicated if a tie occurs.",
    category: "results",
    icon: Vote,
  },
  {
    id: 12,
    question: "Can I vote on my mobile device?",
    answer:
      "Absolutely! Our platform is fully responsive and works seamlessly on smartphones, tablets, and desktop computers. You can vote from any device with internet access. We recommend using a stable internet connection to ensure your vote is submitted successfully.",
    category: "getting-started",
    icon: User,
  },
  {
    id: 13,
    question: "How long do I have to vote?",
    answer:
      "Voting periods vary by election. Each election announcement clearly states the start and end times. Typically, elections are open for 24-72 hours. You'll receive notifications about upcoming elections and reminders as the deadline approaches. Make sure to vote before the election closes, as late votes cannot be accepted.",
    category: "voting",
    icon: Clock,
  },
  {
    id: 14,
    question: "What if I experience technical issues while voting?",
    answer:
      "If you encounter any technical issues, first try refreshing the page or clearing your browser cache. If the problem persists, contact our support team immediately at elections@fisk.edu or use the support chat feature. We provide 24/7 support during active election periods to ensure everyone can vote successfully.",
    category: "getting-started",
    icon: HelpCircle,
  },
  {
    id: 15,
    question: "Are write-in candidates allowed?",
    answer:
      "This depends on the specific election rules. Some elections allow write-in candidates, while others only allow voting for pre-approved candidates. The election announcement will clearly indicate whether write-ins are permitted. If allowed, you'll see a 'Write-in Candidate' option when voting.",
    category: "voting",
    icon: Vote,
  },
];

export default function FAQPage() {
  const [activeCategory, setActiveCategory] = useState("all");
  const [searchQuery, setSearchQuery] = useState("");
  const [openItems, setOpenItems] = useState<number[]>([]);

  const toggleItem = (id: number) => {
    setOpenItems((prev) => (prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]));
  };

  // Filter FAQs
  const filteredFAQs = faqData.filter((faq) => {
    const matchesCategory = activeCategory === "all" || faq.category === activeCategory;
    const matchesSearch =
      searchQuery === "" ||
      faq.question.toLowerCase().includes(searchQuery.toLowerCase()) ||
      faq.answer.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  return (
    <div className="min-h-screen bg-white text-slate-900 flex flex-col">
      <PublicHeader />
      <main className="flex-1">
        {/* Hero Section */}
        <section className="relative overflow-hidden bg-gradient-to-br from-[#0a1a44] via-indigo-900 to-[#8b0000] text-white py-20 sm:py-24 lg:py-28">
          {/* Background Pattern */}
          <div className="absolute inset-0 opacity-10">
            <div
              className="absolute inset-0"
              style={{
                backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='1'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
              }}
            />
          </div>

          {/* Decorative Elements */}
          <div className="absolute top-0 right-0 w-96 h-96 bg-[#f4ba1b]/10 rounded-full blur-3xl" />
          <div className="absolute bottom-0 left-0 w-96 h-96 bg-indigo-500/10 rounded-full blur-3xl" />

          <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center max-w-4xl mx-auto">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[#f4ba1b]/20 backdrop-blur-sm border border-[#f4ba1b]/30 mb-6 mt-8 sm:mt-12">
                <HelpCircle className="w-4 h-4 text-[#f4ba1b]" />
                <span className="text-sm font-semibold text-[#f4ba1b]">Frequently Asked Questions</span>
              </div>

              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold mb-6 leading-tight">
                How Can We Help?
              </h1>
              <p className="text-lg sm:text-xl text-slate-100 mb-8 max-w-2xl mx-auto leading-relaxed">
                Find answers to common questions about voting, elections, security, and more. Can&apos;t
                find what you&apos;re looking for? Contact our support team.
              </p>

              {/* Search Bar */}
              <div className="relative max-w-2xl mx-auto">
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                <input
                  type="text"
                  placeholder="Search for answers..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-12 pr-4 py-3 rounded-xl bg-white/10 backdrop-blur-sm border border-white/20 text-white placeholder:text-slate-300 focus:outline-none focus:ring-2 focus:ring-[#f4ba1b] focus:border-transparent"
                />
              </div>
            </div>
          </div>
        </section>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 sm:py-16">
          {/* Category Filter */}
          <section className="mb-8">
            <div className="flex flex-wrap items-center gap-3">
              {faqCategories.map((category) => {
                const Icon = category.icon;
                return (
                  <button
                    key={category.id}
                    onClick={() => setActiveCategory(category.id)}
                    className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all ${
                      activeCategory === category.id
                        ? "bg-[#f4ba1b] text-slate-900 shadow-md"
                        : "bg-slate-100 text-slate-600 hover:bg-slate-200"
                    }`}
                  >
                    <Icon className="w-4 h-4" />
                    {category.name}
                  </button>
                );
              })}
            </div>
          </section>

          {/* FAQ Items */}
          <section className="space-y-4 mb-12">
            {filteredFAQs.length > 0 ? (
              filteredFAQs.map((faq) => {
                const Icon = faq.icon;
                const isOpen = openItems.includes(faq.id);
                return (
                  <div
                    key={faq.id}
                    className="bg-white border border-slate-200 rounded-xl overflow-hidden hover:shadow-md transition-all"
                  >
                    <button
                      onClick={() => toggleItem(faq.id)}
                      className="w-full flex items-start gap-4 p-6 text-left hover:bg-slate-50 transition-colors"
                    >
                      <div className="flex-shrink-0 w-10 h-10 rounded-lg bg-indigo-100 text-indigo-600 flex items-center justify-center mt-1">
                        <Icon className="w-5 h-5" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <h3 className="text-lg font-bold text-slate-900 mb-2 pr-8">{faq.question}</h3>
                        <div
                          className={`overflow-hidden transition-all duration-300 ${
                            isOpen ? "max-h-[1000px] opacity-100" : "max-h-0 opacity-0"
                          }`}
                        >
                          <p className="text-slate-600 leading-relaxed pt-2">{faq.answer}</p>
                        </div>
                      </div>
                      <div className="flex-shrink-0">
                        <ChevronDown
                          className={`w-5 h-5 text-slate-400 transition-transform duration-300 ${
                            isOpen ? "rotate-180" : ""
                          }`}
                        />
                      </div>
                    </button>
                  </div>
                );
              })
            ) : (
              <div className="text-center py-16">
                <HelpCircle className="w-16 h-16 mx-auto text-slate-300 mb-4" />
                <p className="text-lg font-semibold text-slate-900 mb-2">No results found</p>
                <p className="text-sm text-slate-500">
                  Try adjusting your search or filter criteria
                </p>
              </div>
            )}
          </section>

          {/* Still Need Help Section */}
          <section className="bg-gradient-to-br from-slate-50 to-indigo-50 rounded-3xl p-8 sm:p-12 border border-slate-200">
            <div className="max-w-3xl mx-auto text-center">
              <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-[#f4ba1b]/20 mb-6">
                <MessageCircle className="w-8 h-8 text-[#b48100]" />
              </div>
              <h2 className="text-2xl sm:text-3xl font-bold text-slate-900 mb-4">
                Still Have Questions?
              </h2>
              <p className="text-lg text-slate-600 mb-8">
                Our support team is here to help! Reach out to us and we&apos;ll get back to you as
                soon as possible.
              </p>
              <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
                <Link href="mailto:elections@fisk.edu">
                  <button className="group relative inline-flex items-center gap-3 px-8 py-4 bg-gradient-to-r from-indigo-600 to-indigo-700 text-white font-bold text-sm sm:text-base rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 overflow-hidden">
                    {/* Animated background gradient */}
                    <span className="absolute inset-0 bg-gradient-to-r from-indigo-700 to-purple-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                    
                    {/* Content */}
                    <span className="relative z-10 flex items-center gap-3">
                      <div className="w-5 h-5 flex items-center justify-center">
                        <Mail className="w-5 h-5 text-white group-hover:scale-110 transition-transform duration-300" />
                      </div>
                      <span className="text-white">Contact Support</span>
                    </span>
                    
                    {/* Shine effect */}
                    <span className="absolute inset-0 -translate-x-full group-hover:translate-x-full transition-transform duration-700 bg-gradient-to-r from-transparent via-white/20 to-transparent" />
                  </button>
                </Link>
                <Link href="/about">
                  <Button
                    variant="outline"
                    className="border-2 border-slate-300 text-slate-700 hover:bg-slate-100 hover:border-slate-400 px-6 py-3 font-semibold transition-all"
                  >
                    Learn More About Us
                  </Button>
                </Link>
              </div>
            </div>
          </section>
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}

