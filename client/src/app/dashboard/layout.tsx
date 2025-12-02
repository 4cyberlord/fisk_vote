"use client";

import { ProtectedRoute } from "@/components";
import { DashboardLayout } from "@/components/dashboard/DashboardLayout";

export default function DashboardLayoutWrapper({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ProtectedRoute>
      <DashboardLayout>{children}</DashboardLayout>
    </ProtectedRoute>
  );
}

