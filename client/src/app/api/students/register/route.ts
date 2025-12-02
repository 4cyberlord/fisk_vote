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
      return NextResponse.json(
        {
          success: false,
          message: result.message || "Registration failed",
          errors: result.errors || {},
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

