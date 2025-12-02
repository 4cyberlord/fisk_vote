<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Verify Your Email Address - Fisk Voting System</title>
</head>

<body
    style="font-family: Arial, Helvetica, sans-serif; line-height: 1.6; color: #333333; margin: 0; padding: 0; background-color: #f4f4f4;">
    <table role="presentation" cellpadding="0" cellspacing="0" border="0"
        style="width: 100%; border-collapse: collapse; background-color: #f4f4f4;">
        <tr>
            <td style="padding: 20px 0;" align="center">
                <table role="presentation" cellpadding="0" cellspacing="0" border="0"
                    style="width: 600px; max-width: 100%; margin: 0 auto; background-color: #ffffff; border-collapse: collapse; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                    <tr>
                        <td
                            style="padding: 40px 30px; text-align: center; background-color: #3B82F6; border-radius: 8px 8px 0 0;">
                            <h1 style="color: #ffffff; margin: 0; font-size: 24px; font-weight: normal;">Verify Your
                                Email Address</h1>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 30px;">
                            <p style="margin: 0 0 15px 0; font-size: 16px; color: #333333;">Hello {{ $firstName }},
                            </p>
                            <p style="margin: 0 0 20px 0; font-size: 16px; color: #333333;">Thank you for registering
                                with the Fisk Voting System. Please verify your email address by clicking the button
                                below.</p>

                            <!-- Verification Button -->
                            <div style="text-align: center; margin: 30px 0;">
                                <a href="{{ $verificationUrl }}"
                                    style="display: inline-block; padding: 14px 32px; background-color: #3B82F6; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 16px;">Verify
                                    Email Address</a>
                            </div>

                            <p style="margin: 15px 0 0 0; font-size: 14px; color: #666666; text-align: center;">
                                Or copy and paste this link into your browser:<br>
                                <a href="{{ $verificationUrl }}"
                                    style="color: #3B82F6; word-break: break-all;">{{ $verificationUrl }}</a>
                            </p>

                            <div
                                style="background-color: #fff3cd; padding: 15px; border-radius: 4px; margin: 20px 0; border-left: 4px solid #ffc107;">
                                <p style="margin: 0; font-size: 14px; color: #856404;">
                                    <strong>Important:</strong> This verification link will expire in <strong>2
                                        minutes</strong> and can only be used <strong>once</strong>.
                                </p>
                            </div>

                            <p style="margin: 20px 0 0 0; font-size: 14px; color: #666666;">If you did not create an
                                account, no further action is required.</p>
                        </td>
                    </tr>
                    <tr>
                        <td
                            style="padding: 20px 30px; background-color: #f8f9fa; border-radius: 0 0 8px 8px; text-align: center; border-top: 1px solid #e9ecef;">
                            <p style="margin: 0 0 10px 0; font-size: 12px; color: #999999;">This is an automated email
                                from the Fisk Voting System.</p>
                            <p style="margin: 0; font-size: 11px; color: #999999;">
                                Best regards,<br>
                                Fisk Voting System Team
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>

</html>
