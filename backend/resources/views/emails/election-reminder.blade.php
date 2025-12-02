<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Election Reminder - {{ $election->title }}</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%); padding: 30px; text-align: center; border-radius: 8px 8px 0 0;">
        <h1 style="color: white; margin: 0; font-size: 24px;">Election Reminder</h1>
    </div>
    
    <div style="background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; border: 1px solid #e5e7eb;">
        <p style="font-size: 16px; margin-bottom: 20px;">Hello {{ $user->first_name ?? $user->name }},</p>
        
        <p style="font-size: 16px; margin-bottom: 20px;">
            This is a reminder that the election <strong>{{ $election->title }}</strong> will be starting soon.
        </p>
        
        <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #6366f1;">
            <h2 style="margin-top: 0; color: #1f2937;">{{ $election->title }}</h2>
            @if($election->description)
                <p style="color: #6b7280; margin: 10px 0;">{{ $election->description }}</p>
            @endif
            <p style="margin: 10px 0;">
                <strong>Starts:</strong> {{ \Carbon\Carbon::parse($election->start_time)->format('F j, Y \a\t g:i A') }}
            </p>
            <p style="margin: 10px 0;">
                <strong>Ends:</strong> {{ \Carbon\Carbon::parse($election->end_time)->format('F j, Y \a\t g:i A') }}
            </p>
        </div>
        
        <div style="text-align: center; margin: 30px 0;">
            <a href="{{ env('FRONTEND_URL', 'http://localhost:3000') }}/dashboard/vote" 
               style="display: inline-block; background: #6366f1; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: 600;">
                Cast Your Vote
            </a>
        </div>
        
        <p style="font-size: 14px; color: #6b7280; margin-top: 30px;">
            Thank you for being an active participant in the Fisk Voting System.
        </p>
    </div>
    
    <div style="text-align: center; margin-top: 20px; padding: 20px; color: #9ca3af; font-size: 12px;">
        <p>This is an automated reminder from Fisk Voting System.</p>
        <p>If you have any questions, please contact the election administrators.</p>
    </div>
</body>
</html>

