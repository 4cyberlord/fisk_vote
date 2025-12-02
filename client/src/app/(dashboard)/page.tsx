"use client";

import { ProtectedRoute } from "@/components";
import { useLogout } from "@/hooks/useAuth";
import { Button } from "@/components";

export default function DashboardPage() {
  const logoutMutation = useLogout();

  return (
    <ProtectedRoute>
      <div className="min-h-screen bg-[#0f172a] flex items-center justify-center p-8">
        <div className="max-w-md w-full text-center">
          <h1 className="text-3xl font-bold text-white mb-8">
            Dashboard
          </h1>
          
          <div className="bg-[#1e293b] rounded-lg p-6 border border-white/10">
            <p className="text-gray-400 mb-6">
              Welcome to your dashboard
            </p>
            
            <Button
              onClick={() => logoutMutation.mutate()}
              disabled={logoutMutation.isPending}
              variant="outline"
              fullWidth
            >
              {logoutMutation.isPending ? "Signing out..." : "Sign Out"}
            </Button>
          </div>
        </div>
      </div>
    </ProtectedRoute>
  );
}

