# Hardcoded Data Analysis - Client Pages

This document lists all hardcoded data on client pages that should be pulling from the backend API instead.

---

## Homepage (`client/src/app/page.tsx`)

### 1. **Countdown Timer** (Lines 20-40)
**Issue:** Hardcoded countdown date  
**Current Value:** `"2026-03-15T17:00:00Z"`  
**Location:** Hero section countdown (Lines 85-115)  
**Should Use:** Next upcoming election's `start_time` from `/students/public/elections` API  
**Impact:** Countdown shows incorrect date, not reflecting actual next election

---

### 2. **Upcoming Key Elections Section** (Lines 195-221)
**Issue:** Three hardcoded election cards  
**Current Values:**
- **Card 1:** "Student Senate At‑Large" - Opens Mar 1 · Multiple‑choice ballot
- **Card 2:** "Residence Hall Reps" - Opens Mar 22 · Single‑choice per hall
- **Card 3:** "Clubs & Organizations" - Rolling · Managed by each org

**Location:** Lines 195-221  
**Should Use:** Fetch top 3 upcoming elections from `/students/public/elections` API  
**Impact:** Shows fake elections instead of real upcoming ones

---

### 3. **Election Statistics** (Lines 237-247)
**Issue:** Hardcoded statistics numbers  
**Current Values:**
- `"160+"` campus‑style elections
- `"500"` seeded student scenarios

**Location:** Lines 237-247  
**Should Use:** Actual counts from `/students/public/elections` meta object:
- `meta.total` - Total elections
- `meta.open` - Open elections
- `meta.upcoming` - Upcoming elections
- `meta.closed` - Closed elections

**Impact:** Displays incorrect statistics that don't match actual data

---

### 4. **Featured Campaign Election** (Lines 444-495)
**Issue:** Hardcoded featured election data  
**Current Values:**
- Title: "Spring 2026 · Student Government President"
- Description: "Help shape the next chapter of student leadership at Fisk."
- Uses same hardcoded countdown date

**Location:** Lines 444-495  
**Should Use:** Next major upcoming election from `/students/public/elections`:
- `title` - Election title
- `description` - Election description
- `start_time` - For countdown calculation
- `type` - Election type

**Impact:** Featured section shows fake election instead of real upcoming one

---

### 5. **Campaign Election Cards** (Lines 500-554)
**Issue:** Three hardcoded election cards  
**Current Values:**
- **Card 1:** "Student Government President election" (Spring 2026 · President)
- **Card 2:** "Academic council and class representative seats" (Upcoming · Academic year)
- **Card 3:** "Club, organization, and committee leadership" (Rolling · Throughout the year)

**Location:** Lines 500-554  
**Should Use:** Fetch upcoming elections from `/students/public/elections` API  
**Impact:** Displays fake election cards instead of real upcoming elections

---

### 6. **Statistics Cards** (Lines 670-707)
**Issue:** Hardcoded statistics values  
**Current Values:**
- "Login events (demo): +248"
- "Elections tracked: 160+"
- "Active sessions: Multi‑device" (static text)
- "Result visibility: Live" (static text)

**Location:** Lines 670-707  
**Should Use:** 
- Real statistics from backend (if available)
- Or use public elections meta data for election counts
- Consider creating public stats endpoint if needed

**Impact:** Shows demo/placeholder statistics instead of real data

---

### 7. **Active Supporters/Volunteers** (Lines 347-355)
**Issue:** Hardcoded supporter/volunteer counts  
**Current Values:**
- "Active supporters: 240"
- "Total volunteers: 1,265"

**Location:** Lines 347-355  
**Should Use:** Real statistics if available, or remove if demo-only  
**Impact:** Displays fake engagement metrics

---

### 8. **Notification Card** (Lines 300-308)
**Issue:** Hardcoded election reference  
**Current Value:** "Don't miss the upcoming **Student Government President** election in this demo."

**Location:** Lines 300-308  
**Should Use:** Next upcoming election title from `/students/public/elections`  
**Impact:** Notification references fake election

---

### 9. **Years of Patterns** (Line 414)
**Issue:** Hardcoded years value  
**Current Value:** `"08+"` years

**Location:** Line 414  
**Should Use:** Could be calculated from system start date, or keep as static marketing copy  
**Impact:** Minor - may be intentional marketing copy

---

## Blog & News Page (`client/src/app/blog/page.tsx`)

### 1. **Mock Blog Posts** (Lines 24-160)
**Issue:** All blog posts are hardcoded mock data  
**Current Value:** Array of 9 hardcoded posts with:
- `id`, `title`, `excerpt`, `category`, `author`, `date`, `readTime`, `image`, `featured`

**Location:** Lines 24-160  
**Should Use:** Fetch from backend blog/posts API endpoint (needs to be created)  
**Impact:** Entire blog page shows fake content

**Sample Mock Posts:**
1. "Student Government Elections 2024: Everything You Need to Know"
2. "Meet the Candidates: Student Body President Race"
3. "How to Vote: A Complete Guide for First-Time Voters"
4. "Election Results: Class Representatives Announced"
5. "Campus News: New Voting Policies for 2024"
6. "Student Spotlight: Meet the Rising Leaders"
7. "Ranked Choice Voting Explained"
8. "Election Day Reminders and Important Dates"
9. "Behind the Scenes: How Votes Are Counted"

---

### 2. **Categories with Counts** (Lines 162-170)
**Issue:** Hardcoded category counts  
**Current Values:**
- All: 9
- Announcements: 2
- Candidate Spotlights: 1
- Voting Guides: 2
- Results: 1
- Campus News: 2
- Student Features: 1

**Location:** Lines 162-170  
**Should Use:** Calculate counts dynamically from fetched blog posts  
**Impact:** Category counts don't reflect actual post counts

---

### 3. **Recent Posts** (Line 172)
**Issue:** Derived from mock data  
**Current Value:** `mockPosts.slice(0, 5)` - First 5 posts from mock array

**Location:** Line 172  
**Should Use:** Fetch recent posts from backend, sorted by date  
**Impact:** Shows fake recent posts

---

### 4. **Popular Posts** (Line 173)
**Issue:** Hardcoded array of specific posts  
**Current Value:** `[mockPosts[1], mockPosts[2], mockPosts[4], mockPosts[5], mockPosts[0]]`

**Location:** Line 173  
**Should Use:** Fetch popular posts from backend based on views/engagement metrics  
**Impact:** Shows fake popular posts

---

### 5. **Featured Post** (Line 181)
**Issue:** Derived from mock data  
**Current Value:** `mockPosts.find((post) => post.featured) || mockPosts[0]`

**Location:** Line 181  
**Should Use:** Fetch featured post from backend  
**Impact:** Shows fake featured post

---

### 6. **Author Avatars** (Throughout)
**Issue:** Using placeholder avatar service  
**Current Value:** `https://i.pravatar.cc/150?img=12` (and similar)

**Location:** Multiple locations in post cards  
**Should Use:** Real author avatars from backend user profiles  
**Impact:** Shows placeholder images instead of real author photos

---

### 7. **Newsletter Signup** (Lines 580-597)
**Issue:** No backend integration  
**Current Value:** Static form with no submission handler

**Location:** Lines 580-597  
**Should Use:** Connect to backend newsletter subscription endpoint  
**Impact:** Newsletter signup doesn't work

---

## Main Sections Summary

### Homepage Sections (`client/src/app/page.tsx`)

1. **Hero Section** (Lines 52-173)
   - Countdown timer (hardcoded date)
   - Hero copy (static text - OK)
   - Auth CTAs (dynamic based on auth state - OK)

2. **Upcoming Key Elections** (Lines 175-224)
   - Three hardcoded election cards
   - Should fetch from `/students/public/elections`

3. **Start to Participation** (Lines 226-311)
   - Hardcoded statistics (160+, 500)
   - Notification card with hardcoded election name
   - Should use real election counts

4. **Candidate/Leadership Highlight** (Lines 313-425)
   - Hardcoded supporter/volunteer counts
   - Static content (OK for marketing)
   - Years of patterns (hardcoded)

5. **Featured Campaign Election** (Lines 427-557)
   - Hardcoded featured election
   - Three hardcoded campaign cards
   - Should fetch from `/students/public/elections`

6. **Why Students Trust It** (Lines 559-616)
   - Static informational content (OK)

7. **Security & Transparency** (Lines 618-709)
   - Hardcoded statistics cards
   - Static informational content (OK)

8. **About Our Campaign** (Lines 711-750)
   - Static marketing content (OK)

9. **Final CTA** (Lines 752-770)
   - Static call-to-action (OK)

---

### Blog & News Page Sections (`client/src/app/blog/page.tsx`)

1. **Hero Section** (Lines 215-273)
   - Search functionality (OK - frontend only)
   - Static header text (OK)

2. **Featured Post** (Lines 276-340)
   - Hardcoded featured post from mock data
   - Should fetch from backend

3. **Category Filter Tabs** (Lines 345-370)
   - Hardcoded categories with counts
   - Should calculate from fetched posts

4. **Posts Grid** (Lines 372-483)
   - All posts from mock data
   - Pagination (OK - works with mock data)
   - Should fetch from backend with pagination

5. **Sidebar - Categories** (Lines 488-520)
   - Hardcoded category list with counts
   - Should calculate dynamically

6. **Sidebar - Recent Posts** (Lines 522-550)
   - Derived from mock data
   - Should fetch recent posts from backend

7. **Sidebar - Popular Posts** (Lines 552-578)
   - Hardcoded popular posts array
   - Should fetch based on engagement metrics

8. **Newsletter Signup** (Lines 580-597)
   - No backend integration
   - Should connect to subscription API

---

## Available Backend APIs

### Currently Available:
- ✅ `/api/v1/students/public/elections` - Public elections endpoint
  - Returns: Elections array with meta (total, open, upcoming, closed counts)
  - No authentication required
  - Perfect for homepage election data

### Missing/Needed:
- ❌ Blog/Posts API endpoint - Needs to be created
- ❌ Public statistics endpoint - May need for homepage stats
- ❌ Newsletter subscription endpoint - Needs to be created

---

## Recommendations

### High Priority:
1. **Homepage Elections** - Replace all hardcoded elections with `/students/public/elections` data
2. **Countdown Timer** - Use next upcoming election's `start_time`
3. **Election Statistics** - Use meta counts from public elections API
4. **Blog Posts** - Create blog/posts API endpoint and fetch real data

### Medium Priority:
5. **Statistics Cards** - Create public stats endpoint or use election meta data
6. **Popular Posts** - Add view/engagement tracking to blog system
7. **Newsletter** - Create subscription endpoint

### Low Priority:
8. **Author Avatars** - Connect to user profile photos
9. **Supporters/Volunteers** - Remove or connect to real engagement metrics

---

## Implementation Notes

### For Homepage:
- Use `usePublicElections()` hook (already exists in `client/src/hooks/usePublicElections.ts`)
- Filter elections by `current_status === "Upcoming"` for upcoming sections
- Use `meta` object for statistics
- Calculate countdown from earliest upcoming election's `start_time`

### For Blog Page:
- Need to create blog/posts API endpoint in backend
- Consider adding:
  - `GET /api/v1/blog/posts` - List posts with pagination
  - `GET /api/v1/blog/posts/{id}` - Single post
  - `GET /api/v1/blog/posts/featured` - Featured post
  - `GET /api/v1/blog/posts/popular` - Popular posts
  - `POST /api/v1/newsletter/subscribe` - Newsletter subscription

---

## Summary Statistics

- **Total Hardcoded Items on Homepage:** 9 sections
- **Total Hardcoded Items on Blog Page:** 7 sections
- **Total Sections Analyzed:** 16 sections
- **Backend APIs Available:** 1 (public elections)
- **Backend APIs Needed:** 2+ (blog posts, newsletter, public stats)

---

*Last Updated: Generated from codebase analysis*
