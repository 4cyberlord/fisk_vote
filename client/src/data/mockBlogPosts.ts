// Mock blog posts data with full content
export interface BlogPost {
  id: number;
  title: string;
  excerpt: string;
  content: string;
  category: string;
  author: {
    name: string;
    avatar: string;
  };
  date: string;
  readTime: string;
  image: string;
  featured: boolean;
}

export const mockPosts: BlogPost[] = [
  {
    id: 1,
    title: "Student Government Elections 2024: Everything You Need to Know",
    excerpt:
      "Get ready for the most important election of the year. Learn about the candidates, voting dates, and how to make your voice heard.",
    content: `
      <p class="lead">The 2024 Student Government Elections are here, and this year promises to be one of the most impactful elections in recent history. With multiple positions up for election and a record number of candidates, your vote matters more than ever.</p>

      <h2>Key Dates and Deadlines</h2>
      <p>Mark your calendars! Here are the critical dates you need to know:</p>
      <ul>
        <li><strong>Candidate Registration:</strong> March 1-10, 2024</li>
        <li><strong>Campaign Period:</strong> March 15 - April 5, 2024</li>
        <li><strong>Voting Opens:</strong> April 8, 2024 at 8:00 AM</li>
        <li><strong>Voting Closes:</strong> April 12, 2024 at 11:59 PM</li>
        <li><strong>Results Announcement:</strong> April 15, 2024</li>
      </ul>

      <h2>Positions Up for Election</h2>
      <p>This year, students will be voting for:</p>
      <ul>
        <li>Student Body President</li>
        <li>Vice President</li>
        <li>Secretary</li>
        <li>Treasurer</li>
        <li>Class Representatives (Freshman, Sophomore, Junior, Senior)</li>
        <li>Residence Hall Representatives</li>
      </ul>

      <h2>How to Vote</h2>
      <p>Voting is simple and secure. All eligible students will receive an email with a unique voting link on April 8th. You can vote from any device - your phone, tablet, or computer. The voting process takes less than 5 minutes.</p>

      <p>To be eligible to vote, you must:</p>
      <ul>
        <li>Be a currently enrolled student at Fisk University</li>
        <li>Have a verified university email address</li>
        <li>Be in good academic standing</li>
      </ul>

      <h2>Meet the Candidates</h2>
      <p>This year, we have an impressive slate of candidates running for various positions. Each candidate brings unique perspectives and ideas for improving campus life, student services, and representation.</p>

      <p>Candidate forums and debates will be held throughout the campaign period. Check the events calendar for dates and locations. These forums are your opportunity to hear directly from candidates about their platforms and ask questions.</p>

      <h2>Why Your Vote Matters</h2>
      <p>Student Government plays a crucial role in shaping campus policies, allocating student activity fees, and representing student interests to the administration. The leaders you elect will make decisions that directly impact your college experience.</p>

      <p>Past Student Government initiatives have included:</p>
      <ul>
        <li>Expanding dining hall hours</li>
        <li>Improving campus Wi-Fi infrastructure</li>
        <li>Organizing major campus events and traditions</li>
        <li>Advocating for mental health resources</li>
        <li>Supporting student organizations and clubs</li>
      </ul>

      <h2>Stay Informed</h2>
      <p>Follow our official social media channels and check your email regularly for updates, candidate profiles, and voting reminders. We're committed to ensuring a fair, transparent, and accessible election process.</p>

      <p>If you have any questions about the election process, eligibility, or voting, please contact the Election Committee at <a href="mailto:elections@fisk.edu">elections@fisk.edu</a>.</p>

      <p><strong>Remember:</strong> Your voice matters. Make sure to vote between April 8-12, 2024!</p>
    `,
    category: "Announcements",
    author: {
      name: "Election Committee",
      avatar: "https://i.pravatar.cc/150?img=12",
    },
    date: "March 15, 2024",
    readTime: "5 min read",
    image: "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=800&h=600&fit=crop",
    featured: true,
  },
  {
    id: 2,
    title: "Meet the Candidates: Student Body President Race",
    excerpt:
      "An in-depth look at the three candidates running for Student Body President and their visions for campus.",
    content: `
      <p class="lead">The race for Student Body President is heating up with three exceptional candidates, each bringing unique perspectives and ambitious plans for Fisk University's future.</p>

      <h2>Candidate Profiles</h2>

      <h3>Alexandra Martinez - "Building Bridges"</h3>
      <p>Alexandra, a junior majoring in Political Science, has served as Class Representative for the past two years. Her platform focuses on:</p>
      <ul>
        <li>Strengthening communication between students and administration</li>
        <li>Expanding mental health resources and support services</li>
        <li>Creating more inclusive campus events and traditions</li>
        <li>Improving transparency in Student Government decisions</li>
      </ul>
      <p>"I believe in a Student Government that truly represents every student's voice," says Martinez. "My experience has taught me that real change comes from listening and collaboration."</p>

      <h3>Marcus Johnson - "Innovation and Action"</h3>
      <p>Marcus, a senior Business Administration major, brings experience from leading multiple student organizations. His key priorities include:</p>
      <ul>
        <li>Modernizing campus technology and infrastructure</li>
        <li>Creating more internship and career development opportunities</li>
        <li>Revitalizing campus social spaces</li>
        <li>Establishing a student-run investment fund for campus improvements</li>
      </ul>
      <p>"I'm not here to maintain the status quo," Johnson states. "I want to push Fisk forward with innovative solutions and measurable results."</p>

      <h3>Sarah Chen - "Unity and Progress"</h3>
      <p>Sarah, a junior double-majoring in Sociology and Communications, has been a vocal advocate for student rights. Her platform emphasizes:</p>
      <ul>
        <li>Addressing food insecurity and housing concerns</li>
        <li>Expanding accessibility services and accommodations</li>
        <li>Creating stronger connections between academic departments</li>
        <li>Implementing sustainable campus initiatives</li>
      </ul>
      <p>"Every student deserves to thrive, not just survive," Chen explains. "I'm committed to breaking down barriers and building a more equitable campus community."</p>

      <h2>Upcoming Debates</h2>
      <p>Don't miss the Presidential Candidate Debate scheduled for March 25th at 7:00 PM in the Student Center Auditorium. This will be your chance to hear candidates discuss their platforms and answer questions from students.</p>

      <h2>How to Learn More</h2>
      <p>Each candidate has created detailed platforms available on the Student Government website. You can also follow their campaigns on social media and attend their campaign events throughout March.</p>

      <p>Remember to vote April 8-12, 2024. Your vote will determine who leads Student Government for the 2024-2025 academic year!</p>
    `,
    category: "Candidate Spotlights",
    author: {
      name: "Sarah Johnson",
      avatar: "https://i.pravatar.cc/150?img=33",
    },
    date: "March 12, 2024",
    readTime: "8 min read",
    image: "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop",
    featured: false,
  },
  {
    id: 3,
    title: "How to Vote: A Complete Guide for First-Time Voters",
    excerpt:
      "New to campus elections? This comprehensive guide walks you through the entire voting process step by step.",
    content: `
      <p class="lead">Voting in your first campus election can feel overwhelming, but it doesn't have to be. This guide will walk you through everything you need to know to cast your vote confidently.</p>

      <h2>Step 1: Verify Your Eligibility</h2>
      <p>Before you can vote, make sure you meet the eligibility requirements:</p>
      <ul>
        <li>You must be a currently enrolled student at Fisk University</li>
        <li>Your university email address must be verified</li>
        <li>You must be in good academic standing (not on academic probation)</li>
        <li>You must not have any outstanding disciplinary actions</li>
      </ul>
      <p>If you're unsure about your eligibility, contact the Registrar's Office or the Election Committee.</p>

      <h2>Step 2: Receive Your Voting Link</h2>
      <p>On April 8th at 8:00 AM, all eligible students will receive an email at their university email address. This email contains:</p>
      <ul>
        <li>A unique, secure voting link</li>
        <li>Your voter ID number</li>
        <li>Instructions for voting</li>
        <li>Important dates and deadlines</li>
      </ul>
      <p><strong>Important:</strong> Do not share your voting link with anyone. Each link is unique and can only be used once.</p>

      <h2>Step 3: Review the Candidates</h2>
      <p>Before voting, take time to learn about the candidates:</p>
      <ul>
        <li>Read candidate profiles on the Student Government website</li>
        <li>Attend candidate forums and debates</li>
        <li>Review candidate platforms and policy positions</li>
        <li>Ask questions during Q&A sessions</li>
      </ul>
      <p>Remember, you're voting for people who will represent your interests for an entire academic year. Make an informed decision.</p>

      <h2>Step 4: Cast Your Vote</h2>
      <p>When you're ready to vote:</p>
      <ol>
        <li>Click the voting link in your email (or log in to the voting portal)</li>
        <li>Verify your identity using your student ID</li>
        <li>Review each position and the candidates running</li>
        <li>Select your preferred candidate(s) for each position</li>
        <li>Review your selections carefully</li>
        <li>Submit your ballot</li>
      </ol>

      <h2>Understanding Different Voting Methods</h2>
      
      <h3>Single Choice Voting</h3>
      <p>For positions like President or Vice President, you select one candidate. Simply click on your preferred candidate's name.</p>

      <h3>Multiple Choice Voting</h3>
      <p>For positions like Class Representatives, you may be able to select multiple candidates (up to a specified limit). Check the instructions for each position.</p>

      <h3>Ranked Choice Voting</h3>
      <p>Some positions use ranked choice voting, where you rank candidates in order of preference. This ensures the winner has broad support.</p>

      <h2>Step 5: Confirm Your Vote</h2>
      <p>After submitting your ballot, you'll receive a confirmation email. This confirms that your vote was successfully recorded. Keep this email for your records.</p>

      <h2>Common Questions</h2>
      
      <h3>Can I change my vote?</h3>
      <p>No, once you submit your ballot, it cannot be changed. This ensures the integrity of the election process.</p>

      <h3>What if I don't receive my voting link?</h3>
      <p>Check your spam folder first. If you still don't see it, contact the Election Committee immediately at elections@fisk.edu.</p>

      <h3>Can I vote on my phone?</h3>
      <p>Yes! The voting system is mobile-friendly. You can vote from any device with internet access.</p>

      <h3>How long does voting take?</h3>
      <p>Most students complete their ballot in 3-5 minutes. Take your time to make informed choices.</p>

      <h2>Important Reminders</h2>
      <ul>
        <li>Voting is open from April 8-12, 2024</li>
        <li>Voting closes at 11:59 PM on April 12th - no exceptions</li>
        <li>Your vote is confidential and secure</li>
        <li>If you experience technical issues, contact support immediately</li>
      </ul>

      <p>Remember: Your vote is your voice. Make it count!</p>
    `,
    category: "Voting Guides",
    author: {
      name: "Campus Elections Office",
      avatar: "https://i.pravatar.cc/150?img=45",
    },
    date: "March 10, 2024",
    readTime: "6 min read",
    image: "https://images.unsplash.com/photo-1557804506-669a67965ba0?w=800&h=600&fit=crop",
    featured: false,
  },
  {
    id: 4,
    title: "Election Results: Class Representatives Announced",
    excerpt:
      "The votes are in! See who won the class representative positions and what this means for student governance.",
    content: `
      <p class="lead">The results are in for the Class Representative elections, and we're excited to announce the newly elected leaders who will represent their classes for the 2024-2025 academic year.</p>

      <h2>Freshman Class Representative</h2>
      <p><strong>Winner:</strong> Jordan Williams</p>
      <p>Jordan received 68% of the freshman vote, running on a platform focused on orientation improvements and first-year student support services.</p>
      <p>"I'm honored to represent the Class of 2027," Williams said. "I'm ready to advocate for our needs and ensure our voices are heard."</p>

      <h2>Sophomore Class Representative</h2>
      <p><strong>Winner:</strong> Maya Patel</p>
      <p>Maya won with 72% of the sophomore vote, emphasizing academic support and career development opportunities.</p>
      <p>"I'm excited to work with my classmates to make our sophomore year the best it can be," Patel stated.</p>

      <h2>Junior Class Representative</h2>
      <p><strong>Winner:</strong> David Kim</p>
      <p>David secured 65% of the junior vote, focusing on internship opportunities and graduation preparation.</p>
      <p>"As juniors, we're thinking about our future careers," Kim explained. "I'll work to connect our class with opportunities that matter."</p>

      <h2>Senior Class Representative</h2>
      <p><strong>Winner:</strong> Emily Rodriguez</p>
      <p>Emily won with 71% of the senior vote, running on a platform of legacy building and post-graduation support.</p>
      <p>"This is our last year together," Rodriguez said. "I want to make sure we leave Fisk better than we found it."</p>

      <h2>Voter Turnout</h2>
      <p>This election saw record-breaking participation:</p>
      <ul>
        <li>Freshman: 89% voter turnout</li>
        <li>Sophomore: 85% voter turnout</li>
        <li>Junior: 82% voter turnout</li>
        <li>Senior: 88% voter turnout</li>
      </ul>
      <p>This represents the highest participation rate in the past five years!</p>

      <h2>What's Next?</h2>
      <p>The newly elected representatives will take office on May 1st, 2024. They'll participate in a comprehensive orientation program and begin working on their campaign promises immediately.</p>

      <p>Congratulations to all the winners, and thank you to everyone who voted. Your participation strengthens our campus democracy!</p>
    `,
    category: "Results",
    author: {
      name: "Election Committee",
      avatar: "https://i.pravatar.cc/150?img=12",
    },
    date: "March 8, 2024",
    readTime: "4 min read",
    image: "https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=600&fit=crop",
    featured: false,
  },
  {
    id: 5,
    title: "Campus News: New Voting Policies for 2024",
    excerpt:
      "Important updates to election policies that all students should be aware of before casting their votes.",
    content: `
      <p class="lead">The Election Committee has announced several important policy updates for the 2024 election cycle. These changes are designed to improve accessibility, security, and transparency.</p>

      <h2>Extended Voting Hours</h2>
      <p>Voting will now be available 24/7 during the election period. Previously, voting was only available during business hours. This change ensures that students with varying schedules can participate.</p>
      <p><strong>New Schedule:</strong> April 8, 8:00 AM - April 12, 11:59 PM (24/7 access)</p>

      <h2>Ranked Choice Voting Expansion</h2>
      <p>Ranked choice voting will now be used for all multi-candidate races, not just the Presidential election. This ensures that winners have broad support from the student body.</p>
      <p>How it works: Instead of selecting just one candidate, you'll rank candidates in order of preference (1st, 2nd, 3rd, etc.). If no candidate receives a majority of first-choice votes, the candidate with the fewest votes is eliminated, and their votes are redistributed based on second choices. This process continues until a candidate receives a majority.</p>

      <h2>Enhanced Accessibility Features</h2>
      <p>The voting system now includes:</p>
      <ul>
        <li>Screen reader compatibility</li>
        <li>High contrast mode</li>
        <li>Text size adjustment options</li>
        <li>Keyboard navigation support</li>
        <li>Multi-language support (Spanish, French, and ASL resources available)</li>
      </ul>

      <h2>Campaign Finance Transparency</h2>
      <p>All candidates are now required to disclose campaign spending. This information will be publicly available on the Student Government website, promoting transparency and accountability.</p>
      <p>Campaign spending limits:</p>
      <ul>
        <li>Presidential candidates: $500 maximum</li>
        <li>Vice Presidential candidates: $300 maximum</li>
        <li>Other positions: $200 maximum</li>
      </ul>

      <h2>Voter Verification Improvements</h2>
      <p>The verification process has been streamlined while maintaining security. Students can now verify their identity using:</p>
      <ul>
        <li>Student ID number</li>
        <li>University email address</li>
        <li>Biometric verification (optional, for enhanced security)</li>
      </ul>

      <h2>Results Timeline</h2>
      <p>Election results will be announced within 48 hours of voting closing, down from the previous 72-hour window. This faster timeline provides quicker feedback while ensuring accurate vote counting.</p>

      <h2>Appeal Process</h2>
      <p>A new, streamlined appeals process has been established for students who believe their vote was not counted correctly or who have concerns about the election process. Appeals must be submitted within 24 hours of results being announced.</p>

      <h2>Questions?</h2>
      <p>If you have questions about these policy changes, attend the Election Policy Forum on March 20th at 6:00 PM in the Student Center, or contact the Election Committee at elections@fisk.edu.</p>

      <p>These updates reflect our commitment to fair, accessible, and transparent elections. We encourage all eligible students to participate!</p>
    `,
    category: "Campus News",
    author: {
      name: "Administration",
      avatar: "https://i.pravatar.cc/150?img=67",
    },
    date: "March 5, 2024",
    readTime: "7 min read",
    image: "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800&h=600&fit=crop",
    featured: false,
  },
  {
    id: 6,
    title: "Student Spotlight: Meet the Rising Leaders",
    excerpt:
      "Get to know the students who are making a difference on campus and running for leadership positions.",
    content: `
      <p class="lead">This election season, we're highlighting the incredible students who have stepped up to lead. These rising leaders represent the best of Fisk University's student body.</p>

      <h2>Leadership in Action</h2>
      <p>Across campus, students are demonstrating leadership in various ways - from organizing community service projects to advocating for policy changes. Many of these leaders are now running for Student Government positions.</p>

      <h2>Notable Candidates</h2>

      <h3>Community Organizers</h3>
      <p>Several candidates have distinguished themselves through community organizing:</p>
      <ul>
        <li><strong>Alexandra Martinez</strong> organized the campus-wide food drive that collected over 2,000 pounds of food for local families</li>
        <li><strong>Marcus Johnson</strong> founded the Entrepreneurship Club and has helped 15 students launch their own businesses</li>
        <li><strong>Sarah Chen</strong> led the campaign to expand mental health resources, resulting in the hiring of two additional counselors</li>
      </ul>

      <h3>Academic Excellence</h3>
      <p>Many candidates excel academically while maintaining leadership roles:</p>
      <ul>
        <li>85% of candidates maintain a GPA above 3.5</li>
        <li>Several candidates are members of honor societies</li>
        <li>Many are involved in research projects and academic publications</li>
      </ul>

      <h3>Diverse Perspectives</h3>
      <p>This year's candidate pool represents remarkable diversity:</p>
      <ul>
        <li>Representation from all academic departments</li>
        <li>Candidates from various cultural and socioeconomic backgrounds</li>
        <li>Mix of class years (freshmen through seniors)</li>
        <li>Students with different leadership styles and approaches</li>
      </ul>

      <h2>Why They're Running</h2>
      <p>When asked why they're running for office, candidates consistently mention:</p>
      <ul>
        <li>A desire to give back to the Fisk community</li>
        <li>Passion for specific issues affecting students</li>
        <li>Belief in the power of student voice and representation</li>
        <li>Commitment to making positive change</li>
      </ul>

      <h2>Get Involved</h2>
      <p>Even if you're not running for office, you can support these rising leaders:</p>
      <ul>
        <li>Attend candidate forums and debates</li>
        <li>Volunteer for campaigns</li>
        <li>Share information about candidates and elections</li>
        <li>Most importantly - vote!</li>
      </ul>

      <h2>Looking Ahead</h2>
      <p>These students represent the future of Fisk University. Their leadership, both in Student Government and across campus, will shape the university for years to come.</p>

      <p>We're excited to see what these rising leaders will accomplish. Make sure to vote April 8-12 to support the candidates who inspire you!</p>
    `,
    category: "Student Features",
    author: {
      name: "Campus Media",
      avatar: "https://i.pravatar.cc/150?img=23",
    },
    date: "March 3, 2024",
    readTime: "9 min read",
    image: "https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=800&h=600&fit=crop",
    featured: false,
  },
  {
    id: 7,
    title: "Ranked Choice Voting Explained",
    excerpt:
      "Understanding how ranked choice voting works and why it's being used in this year's elections.",
    content: `
      <p class="lead">Ranked choice voting is being used in this year's elections for the first time. This guide will help you understand how it works and why it's beneficial for campus democracy.</p>

      <h2>What is Ranked Choice Voting?</h2>
      <p>Ranked choice voting (RCV) allows you to rank candidates in order of preference rather than selecting just one. This system ensures that winners have broad support from the student body.</p>

      <h2>How It Works</h2>
      <p>When you vote using ranked choice:</p>
      <ol>
        <li>You rank candidates in order of preference (1st choice, 2nd choice, 3rd choice, etc.)</li>
        <li>If your first-choice candidate receives a majority (more than 50%) of first-choice votes, they win</li>
        <li>If no candidate receives a majority, the candidate with the fewest first-choice votes is eliminated</li>
        <li>Votes for the eliminated candidate are redistributed to those voters' second-choice candidates</li>
        <li>This process continues until one candidate receives a majority</li>
      </ol>

      <h2>Example Scenario</h2>
      <p>Imagine an election with three candidates: Alex, Morgan, and Sam.</p>
      <p><strong>Initial Results:</strong></p>
      <ul>
        <li>Alex: 35% (1st choice votes)</li>
        <li>Morgan: 30% (1st choice votes)</li>
        <li>Sam: 35% (1st choice votes)</li>
      </ul>
      <p>No candidate has a majority (50%+), so Sam (with the fewest votes) is eliminated. Sam's voters had ranked Morgan as their second choice, so those votes go to Morgan.</p>
      <p><strong>Final Results:</strong></p>
      <ul>
        <li>Alex: 35%</li>
        <li>Morgan: 65% (30% + 35% from Sam's voters)</li>
      </ul>
      <p>Morgan wins with 65% support!</p>

      <h2>Benefits of Ranked Choice Voting</h2>
      
      <h3>1. Promotes Majority Support</h3>
      <p>Winners must receive majority support, either initially or through the redistribution process. This ensures broad consensus.</p>

      <h3>2. Reduces Negative Campaigning</h3>
      <p>Candidates have an incentive to appeal to a broader base of voters, not just their core supporters. This can lead to more positive campaigns.</p>

      <h3>3. Eliminates "Spoiler" Effect</h3>
      <p>Students can vote for their preferred candidate without worrying about "wasting" their vote. If their first choice doesn't win, their second choice still matters.</p>

      <h3>4. Encourages Diverse Candidates</h3>
      <p>More candidates can run without fear of splitting the vote, leading to more diverse representation.</p>

      <h2>How to Vote</h2>
      <p>When you access your ballot:</p>
      <ol>
        <li>Review all candidates for the position</li>
        <li>Rank them in order of preference (1 = most preferred)</li>
        <li>You don't have to rank all candidates - only rank those you support</li>
        <li>Submit your ballot</li>
      </ol>

      <h2>Common Questions</h2>
      
      <h3>Do I have to rank all candidates?</h3>
      <p>No. You only need to rank the candidates you support. If you only like one candidate, you can rank just that person.</p>

      <h3>What if I only rank one candidate?</h3>
      <p>That's perfectly fine! If your candidate is eliminated, your vote won't be redistributed, but you've still expressed your preference.</p>

      <h3>Can I rank candidates equally?</h3>
      <p>No, you must rank candidates in order. If you truly have no preference between two candidates, rank them based on any criteria that matters to you.</p>

      <h3>Is ranked choice voting complicated?</h3>
      <p>Not at all! The voting system handles all the calculations automatically. You just rank your preferences, and the system does the rest.</p>

      <h2>Why We're Using It</h2>
      <p>After extensive research and student feedback, the Election Committee determined that ranked choice voting best serves our campus community. It ensures that elected leaders have broad support and encourages positive, issue-focused campaigns.</p>

      <h2>Learn More</h2>
      <p>If you have questions about ranked choice voting, attend our informational session on March 18th at 5:00 PM in the Student Center, or contact the Election Committee.</p>

      <p>Remember: Your vote matters, and ranked choice voting ensures your voice is heard even if your first choice doesn't win!</p>
    `,
    category: "Voting Guides",
    author: {
      name: "Election Committee",
      avatar: "https://i.pravatar.cc/150?img=12",
    },
    date: "March 1, 2024",
    readTime: "5 min read",
    image: "https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=800&h=600&fit=crop",
    featured: false,
  },
  {
    id: 8,
    title: "Election Day Reminders and Important Dates",
    excerpt:
      "Mark your calendars! Here are all the important dates and deadlines you need to know for the upcoming elections.",
    content: `
      <p class="lead">With election season approaching, it's crucial to stay informed about all important dates and deadlines. Mark your calendars now to ensure you don't miss any critical events!</p>

      <h2>Key Dates Timeline</h2>

      <h3>March 1-10: Candidate Registration</h3>
      <p>Students interested in running for office must submit their candidacy applications during this period. Applications are available online and at the Student Government office.</p>
      <p><strong>Deadline:</strong> March 10, 2024 at 11:59 PM - No exceptions!</p>

      <h3>March 12-14: Candidate Verification</h3>
      <p>The Election Committee reviews all applications and verifies candidate eligibility. Approved candidates will be notified by March 14th.</p>

      <h3>March 15 - April 5: Campaign Period</h3>
      <p>This is when candidates can actively campaign. Key events during this period:</p>
      <ul>
        <li><strong>March 18:</strong> Ranked Choice Voting Information Session</li>
        <li><strong>March 20:</strong> Election Policy Forum</li>
        <li><strong>March 25:</strong> Presidential Candidate Debate</li>
        <li><strong>March 28:</strong> Vice Presidential Candidate Forum</li>
        <li><strong>April 2:</strong> All-Candidate Meet & Greet</li>
      </ul>

      <h3>April 5: Campaign Blackout Period Begins</h3>
      <p>At 11:59 PM on April 5th, all campaigning must stop. This 48-hour blackout period ensures a fair voting environment.</p>

      <h3>April 8-12: Voting Period</h3>
      <p><strong>Voting Opens:</strong> April 8, 2024 at 8:00 AM</p>
      <p><strong>Voting Closes:</strong> April 12, 2024 at 11:59 PM</p>
      <p>Voting is available 24/7 during this period. You'll receive your unique voting link via email on April 8th.</p>

      <h3>April 13-14: Vote Counting and Verification</h3>
      <p>The Election Committee counts votes and verifies results. This process is transparent and can be observed by student representatives.</p>

      <h3>April 15: Results Announcement</h3>
      <p>Election results will be announced at 12:00 PM in the Student Center. Results will also be posted online and sent via email to all students.</p>

      <h2>Important Reminders</h2>

      <h3>For Voters</h3>
      <ul>
        <li>Check your email regularly - your voting link will be sent on April 8th</li>
        <li>Verify your eligibility before election day</li>
        <li>Attend candidate forums to make informed decisions</li>
        <li>Vote early to avoid technical issues or forgotten deadlines</li>
        <li>Keep your confirmation email after voting</li>
      </ul>

      <h3>For Candidates</h3>
      <ul>
        <li>Submit your application by March 10th</li>
        <li>Attend mandatory candidate orientation on March 11th</li>
        <li>Follow all campaign finance rules</li>
        <li>Respect the campaign blackout period</li>
        <li>Submit campaign spending reports by April 6th</li>
      </ul>

      <h2>Where to Get Information</h2>
      <ul>
        <li><strong>Student Government Office:</strong> Open Monday-Friday, 9 AM - 5 PM</li>
        <li><strong>Email:</strong> elections@fisk.edu</li>
        <li><strong>Website:</strong> studentgov.fisk.edu/elections</li>
        <li><strong>Social Media:</strong> @FiskStudentGov on all platforms</li>
      </ul>

      <h2>What to Do If You Miss a Deadline</h2>
      <p>If you miss a deadline, contact the Election Committee immediately. While most deadlines are firm, exceptions may be made for extenuating circumstances (illness, family emergency, etc.).</p>

      <h2>Stay Connected</h2>
      <p>Follow the Student Government social media accounts and check your email regularly for updates, reminders, and important announcements.</p>

      <p><strong>Remember:</strong> These dates are subject to change. Always check official communications for the most up-to-date information!</p>

      <p>Mark your calendars now and get ready for an exciting election season!</p>
    `,
    category: "Announcements",
    author: {
      name: "Election Committee",
      avatar: "https://i.pravatar.cc/150?img=12",
    },
    date: "February 28, 2024",
    readTime: "3 min read",
    image: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800&h=600&fit=crop",
    featured: false,
  },
  {
    id: 9,
    title: "Behind the Scenes: How Votes Are Counted",
    excerpt:
      "A transparent look at the secure voting process and how we ensure every vote is counted accurately.",
    content: `
      <p class="lead">Transparency is fundamental to our election process. This article takes you behind the scenes to show exactly how votes are counted and verified, ensuring confidence in our democratic system.</p>

      <h2>The Voting System</h2>
      <p>Our voting system uses state-of-the-art encryption and security measures to protect your vote while ensuring accurate counting.</p>

      <h3>Step 1: Vote Submission</h3>
      <p>When you submit your ballot:</p>
      <ul>
        <li>Your vote is immediately encrypted</li>
        <li>A unique confirmation code is generated</li>
        <li>Your vote is stored securely in multiple redundant systems</li>
        <li>You receive a confirmation email</li>
      </ul>
      <p>At no point can your individual vote be traced back to you - your privacy is protected.</p>

      <h3>Step 2: Vote Verification</h3>
      <p>After voting closes, the system automatically:</p>
      <ul>
        <li>Verifies that each vote came from an eligible student</li>
        <li>Checks for duplicate votes (each student can only vote once)</li>
        <li>Validates that votes are properly formatted</li>
        <li>Ensures no votes were tampered with</li>
      </ul>

      <h3>Step 3: Vote Counting</h3>
      <p>For single-choice elections, votes are counted directly. For ranked choice voting:</p>
      <ol>
        <li>First-choice votes are counted</li>
        <li>If no candidate has a majority, the candidate with fewest votes is eliminated</li>
        <li>Eliminated candidates' votes are redistributed based on second choices</li>
        <li>This process continues until a candidate receives a majority</li>
        <li>All calculations are logged and can be audited</li>
      </ol>

      <h2>Security Measures</h2>

      <h3>Encryption</h3>
      <p>All votes are encrypted using industry-standard encryption (AES-256). This means that even if someone accessed the database, they couldn't read individual votes.</p>

      <h3>Blockchain Verification</h3>
      <p>We use blockchain technology to create an immutable record of all votes. Once recorded, votes cannot be altered or deleted.</p>

      <h3>Multi-Factor Authentication</h3>
      <p>Voters must verify their identity using multiple factors:</p>
      <ul>
        <li>Student ID number</li>
        <li>University email address</li>
        <li>Unique voting link</li>
      </ul>

      <h3>Audit Logs</h3>
      <p>Every action in the voting system is logged:</p>
      <ul>
        <li>When votes are submitted</li>
        <li>When votes are counted</li>
        <li>Who accessed the system</li>
        <li>Any errors or anomalies</li>
      </ul>
      <p>These logs are reviewed by independent auditors.</p>

      <h2>Transparency Measures</h2>

      <h3>Public Observers</h3>
      <p>Student representatives from various organizations are invited to observe the vote counting process. This ensures transparency and builds trust.</p>

      <h3>Real-Time Updates</h3>
      <p>During the counting process, we provide real-time updates on:</p>
      <ul>
        <li>Total votes cast</li>
        <li>Vote counts by position</li>
        <li>Progress of ranked choice calculations</li>
      </ul>

      <h3>Post-Election Report</h3>
      <p>After results are announced, we publish a detailed report including:</p>
      <ul>
        <li>Total voter turnout</li>
        <li>Vote counts for each candidate</li>
        <li>Breakdown by class year, department, etc. (anonymized)</li>
        <li>Any issues encountered and how they were resolved</li>
      </ul>

      <h2>Verification Process</h2>
      <p>After votes are counted, multiple verification steps ensure accuracy:</p>
      <ol>
        <li><strong>Automated Checks:</strong> The system automatically verifies vote totals</li>
        <li><strong>Manual Review:</strong> Election Committee members manually review results</li>
        <li><strong>Independent Audit:</strong> External auditors review a random sample of votes</li>
        <li><strong>Student Verification:</strong> Students can request to verify their vote was counted (without seeing how they voted)</li>
      </ol>

      <h2>Common Concerns Addressed</h2>

      <h3>"Can my vote be changed?"</h3>
      <p>No. Once submitted, votes are encrypted and stored immutably. They cannot be altered.</p>

      <h3>"Can someone see how I voted?"</h3>
      <p>No. The system separates voter identity from vote choice. We know who voted, but not how they voted.</p>

      <h3>"What if there's a technical error?"</h3>
      <p>We have multiple backup systems. If there's an issue, we can recover votes from backups. All technical issues are logged and addressed immediately.</p>

      <h3>"How do I know my vote counted?"</h3>
      <p>You receive a confirmation email immediately after voting. After results are announced, you can verify that your vote was counted (without seeing how you voted) by contacting the Election Committee.</p>

      <h2>Continuous Improvement</h2>
      <p>We're constantly improving our voting system based on:</p>
      <ul>
        <li>Student feedback</li>
        <li>Security best practices</li>
        <li>Technological advances</li>
        <li>Lessons learned from each election</li>
      </ul>

      <h2>Questions?</h2>
      <p>If you have questions about the voting or counting process, we encourage you to:</p>
      <ul>
        <li>Attend our "How Votes Are Counted" information session</li>
        <li>Contact the Election Committee</li>
        <li>Request to observe the vote counting process</li>
        <li>Review our published election reports</li>
      </ul>

      <p>Transparency builds trust. We're committed to ensuring that every student can have confidence in our election process!</p>
    `,
    category: "Campus News",
    author: {
      name: "Election Committee",
      avatar: "https://i.pravatar.cc/150?img=12",
    },
    date: "February 25, 2024",
    readTime: "6 min read",
    image: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=600&fit=crop",
    featured: false,
  },
];

// Helper function to get a post by ID
export function getPostById(id: number): BlogPost | undefined {
  return mockPosts.find((post) => post.id === id);
}

// Helper function to get related posts (same category, excluding current post)
export function getRelatedPosts(currentPostId: number, limit: number = 3): BlogPost[] {
  const currentPost = getPostById(currentPostId);
  if (!currentPost) return [];

  return mockPosts
    .filter((post) => post.id !== currentPostId && post.category === currentPost.category)
    .slice(0, limit);
}

// Helper function to get recent posts (excluding current post)
export function getRecentPosts(currentPostId: number, limit: number = 3): BlogPost[] {
  return mockPosts
    .filter((post) => post.id !== currentPostId)
    .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
    .slice(0, limit);
}
