import { NextRequest, NextResponse } from "next/server";

const BACKEND_URL = process.env.NEXT_PUBLIC_BACKEND_URL || "http://localhost:8000";

export async function POST(request: NextRequest) {
  try {
    const data = await request.json();

    const response = await fetch(`${BACKEND_URL}/api/v1/students/register`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
      body: JSON.stringify(data),
    });

    const result = await response.json();

    if (!response.ok) {
      // Normalize error response so the client never sees low-level or
      // infrastructure details. For 4xx we surface validation-style messages,
      // for 5xx we always return a generic message.
      const isServerError = response.status >= 500;

      const safeMessage = isServerError
        ? "Something went wrong on our side while creating your account. Please try again in a few minutes."
        : result.message || "Registration failed";

      return NextResponse.json(
        {
          success: false,
          message: safeMessage,
          // Only pass through validation-style errors; backend 5xx payloads
          // (like email configuration issues) are intentionally hidden.
          errors: isServerError ? {} : result.errors || {},
        },
        { status: response.status }
      );
    }

    return NextResponse.json(result, { status: 201 });
  } catch (error) {
    console.error("Registration API error:", error);
    return NextResponse.json(
      {
        success: false,
        message: "Failed to connect to server. Please try again later.",
      },
      { status: 500 }
    );
  }
}

