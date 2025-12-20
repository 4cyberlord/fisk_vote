"use client";

import { ProtectedRoute } from "@/components";
import { DashboardLayout } from "@/components/dashboard/DashboardLayout";
import { ProfileCompletionModal } from "@/components/profile/ProfileCompletionModal";

export default function DashboardLayoutWrapper({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ProtectedRoute>
      <DashboardLayout>{children}</DashboardLayout>
      <ProfileCompletionModal />
    </ProtectedRoute>
  );
}

