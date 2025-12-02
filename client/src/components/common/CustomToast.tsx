"use client";

import { Toaster, ToastBar, toast } from "react-hot-toast";

export function CustomToaster() {
  return (
    <Toaster
      position="top-right"
      containerClassName="!top-6 !right-6"
      toastOptions={{
        duration: 90000, // 1.5 minutes (90 seconds) - increased duration for better readability
        className: "",
        style: {
          background: "transparent",
          boxShadow: "none",
          padding: 0,
          margin: 0,
        },
        success: {
          iconTheme: {
            primary: "transparent",
            secondary: "transparent",
          },
        },
        error: {
          iconTheme: {
            primary: "transparent",
            secondary: "transparent",
          },
        },
      }}
    >
      {(t) => {
        const isSuccess = t.type === "success";
        const isError = t.type === "error";
        
        // Get the message from the toast object directly
        // t.message can be a string or ReactNode, so we need to extract the string
        let messageText = "";
        
        if (typeof t.message === "string") {
          messageText = t.message;
        } else if (t.message && typeof t.message === "object") {
          // Check if it's a React element with props.children
          const reactElement = t.message as { props?: { children?: unknown } };
          if (reactElement?.props?.children) {
            // Try to extract text from children
            const children = reactElement.props.children;
            if (typeof children === "string") {
              messageText = children;
            } else if (Array.isArray(children)) {
              messageText = children
                .map((child: unknown) => (typeof child === "string" ? child : ""))
                .join("");
            } else {
              messageText = String(children);
            }
          } else {
            // Fallback: try to stringify
            messageText = String(t.message);
            // If it's [object Object], try to get a meaningful string
            if (messageText === "[object Object]") {
              try {
                messageText = JSON.stringify(t.message) || "Notification";
              } catch {
                messageText = "Notification";
              }
            }
          }
        } else {
          messageText = String(t.message || "");
        }
        
        // Clean up messageText - remove [object Object] if present
        if (messageText.includes("[object Object]")) {
          messageText = messageText.replace(/\[object Object\]/g, "").trim();
          if (!messageText) {
            messageText = isSuccess ? "Operation completed successfully!" : isError ? "An error occurred" : "Notification";
          }
        }
        
        // Parse message - check if it's a multi-line string
        let title = "";
        let description = "";
        
        if (messageText.includes("\n")) {
          const parts = messageText.split("\n");
          title = parts[0];
          description = parts.slice(1).join(" ");
        } else {
          // Single line message
          title = isSuccess ? "Success!" : isError ? "Error" : "Notification";
          description = messageText;
        }
        
        return (
          <div className="animate-fade-in">
            <ToastBar toast={t}>
              {() => (
                <div className="flex items-start gap-3 bg-white border border-gray-200 rounded-xl shadow-[0_4px_20px_rgba(0,0,0,0.08)] px-5 py-4 w-[320px]">
                  {/* Icon */}
                  <div
                    className={`mt-1 flex items-center justify-center w-6 h-6 rounded-full flex-shrink-0 ${
                      isSuccess
                        ? "bg-green-50 text-green-600"
                        : isError
                        ? "bg-red-50 text-red-600"
                        : "bg-blue-50 text-blue-600"
                    }`}
                  >
                    {isSuccess ? (
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        className="h-4 w-4"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                        strokeWidth="2"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          d="M9 12l2 2l4-4m6 2a9 9 0 11-18 0a9 9 0 0118 0z"
                        />
                      </svg>
                    ) : isError ? (
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        className="h-4 w-4"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                        strokeWidth="2"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0a9 9 0 0118 0z"
                        />
                      </svg>
                    ) : (
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        className="h-4 w-4"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                        strokeWidth="2"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0a9 9 0 0118 0z"
                        />
                      </svg>
                    )}
                  </div>

                  {/* Text */}
                  <div className="flex-1 min-w-0">
                    <p className="text-gray-900 font-medium">{title}</p>
                    <p className="text-gray-500 text-sm mt-0.5 break-words">
                      {description}
                    </p>
                  </div>

                  {/* Close Button */}
                  <button
                    onClick={() => toast.dismiss(t.id)}
                    className="text-gray-400 hover:text-gray-600 transition mt-1 flex-shrink-0"
                    aria-label="Close"
                  >
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      className="h-4 w-4"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                      strokeWidth="2"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        d="M6 18L18 6M6 6l12 12"
                      />
                    </svg>
                  </button>
                </div>
              )}
            </ToastBar>
          </div>
        );
      }}
    </Toaster>
  );
}
