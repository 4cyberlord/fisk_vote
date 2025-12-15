# Notification System Implementation

## Overview
A complete backend-driven notification system has been implemented for the voting application. Notifications are now triggered from the backend based on election and vote events, stored in the database, and fetched via API.

## Components Created

### 1. Database
- **Migration**: `2025_12_14_190144_create_notifications_table.php`
- **Model**: `App\Models\Notification`
- **Table**: `notifications`
  - Stores: user_id, type, title, message, icon, color, href, is_read, urgent, metadata, read_at

### 2. Backend Services
- **NotificationService** (`app/Services/NotificationService.php`)
  - Helper methods to create notifications
  - Methods: `notifyElectionOpened()`, `notifyElectionUpcoming()`, `notifyElectionClosingSoon()`, `notifyVoteConfirmed()`, `notifyResultsAvailable()`

### 3. Observers
- **ElectionObserver** (`app/Observers/ElectionObserver.php`)
  - Triggers notifications when elections are created/updated
  - Detects when elections open and notifies eligible users
  
- **VoteObserver** (`app/Observers/VoteObserver.php`)
  - Triggers notifications when votes are cast
  - Creates vote confirmation notifications

### 4. Scheduled Command
- **CheckElectionNotifications** (`app/Console/Commands/CheckElectionNotifications.php`)
  - Runs hourly to check for upcoming/closing elections
  - Creates notifications for elections starting/closing soon
  - Scheduled in `routes/console.php`

### 5. API Endpoints
- **GET** `/api/v1/students/notifications` - Get all notifications
- **GET** `/api/v1/students/notifications/unread-count` - Get unread count
- **POST** `/api/v1/students/notifications/{id}/read` - Mark as read
- **POST** `/api/v1/students/notifications/read-all` - Mark all as read

### 6. Frontend Integration
- **Service**: `client/src/services/notificationService.ts`
- **Hooks**: `client/src/hooks/useNotifications.ts`
- **Updated**: `client/src/components/dashboard/DashboardLayout.tsx`
  - Now fetches notifications from API instead of computing client-side
  - Auto-refreshes every 60 seconds

## How Notifications Are Triggered

### 1. Election Opens
- **Trigger**: When an election's status changes to 'active' and start_time is within the last hour
- **Observer**: `ElectionObserver::updated()`
- **Action**: Creates "New Election Available" notifications for all eligible users who haven't voted

### 2. Election Upcoming
- **Trigger**: Scheduled command runs hourly, checks for elections starting within 24-48 hours
- **Command**: `notifications:check-elections`
- **Action**: Creates "Election Starting Soon" notifications

### 3. Election Closing Soon
- **Trigger**: Scheduled command checks for elections closing within 24 hours
- **Command**: `notifications:check-elections`
- **Action**: Creates "Election Closing Soon" urgent notifications for users who haven't voted

### 4. Vote Confirmed
- **Trigger**: When a vote is created
- **Observer**: `VoteObserver::created()`
- **Action**: Creates "Vote Confirmed" notification for the voter

### 5. Results Available
- **Trigger**: When election status changes to 'closed' (can be extended)
- **Action**: Creates "Results Available" notifications for all voters

## Testing

### Test Seeder
Run the test seeder to create sample notifications:
```bash
php artisan db:seed --class=NotificationTestSeeder
```

This creates 4 test notifications (2 unread, 2 read) for the first student user.

### Manual Testing
1. **Create an election** that starts now - should trigger "New Election Available" notifications
2. **Cast a vote** - should trigger "Vote Confirmed" notification
3. **Run scheduled command**:
   ```bash
   php artisan notifications:check-elections
   ```
   This will check for upcoming/closing elections and create notifications

### API Testing
```bash
# Get notifications (requires authentication)
GET /api/v1/students/notifications

# Get unread count
GET /api/v1/students/notifications/unread-count

# Mark notification as read
POST /api/v1/students/notifications/{id}/read

# Mark all as read
POST /api/v1/students/notifications/read-all
```

## Scheduled Tasks

The notification check command runs **hourly** automatically:
- Checks for elections starting within 48 hours
- Checks for elections closing within 24 hours
- Creates appropriate notifications

To run manually:
```bash
php artisan notifications:check-elections
```

## Notification Types

1. **new_election** - Blue, urgent, bell icon
2. **upcoming** - Amber, clock icon (urgent if <24 hours)
3. **closing_soon** - Red, urgent, alert-circle icon
4. **vote_confirmed** - Green, check-circle icon
5. **results_available** - Purple, award icon

## Frontend Features

- ✅ Real-time notification fetching from API
- ✅ Auto-refresh every 60 seconds
- ✅ Unread count badge
- ✅ Mark as read on click
- ✅ Mark all as read button
- ✅ Visual indicators (unread dot, urgent highlighting)
- ✅ Empty state when no notifications
- ✅ Loading states

## Next Steps (Optional Enhancements)

1. **Real-time updates**: Add WebSocket/Pusher integration for instant notifications
2. **Email notifications**: Integrate with existing email system
3. **Push notifications**: Browser push notifications
4. **Notification preferences**: Let users choose which notifications to receive
5. **Notification history**: Keep read notifications for longer periods
