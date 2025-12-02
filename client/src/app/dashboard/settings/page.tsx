"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import {
  Lock,
  Eye,
  EyeOff,
  CheckCircle2,
  Bell,
  Palette,
  Shield,
  User,
  Accessibility,
  FileText,
  Smartphone,
  Clock,
  History,
  Download,
  Trash2,
  Mail,
  MessageCircle,
  ExternalLink,
  Globe,
  Monitor,
  Activity,
  MapPin,
  CheckCircle,
  XCircle,
  AlertCircle,
  LogOut,
  Edit,
} from "lucide-react";
import toast from "react-hot-toast";
import { api } from "@/lib/axios";
import { useAuditLogs, type AuditLog } from "@/hooks/useAuditLogs";
import {
  useSessions,
  useRevokeSession,
  useRevokeAllOtherSessions,
  useRevokeAllSessions,
} from "@/hooks/useSessions";
import { Pagination, ConfirmationModal } from "@/components";
import { useRouter } from "next/navigation";
import { useLogout } from "@/hooks/useAuth";

const AUDIT_LOGS_PER_PAGE = 10;

type TabType = "security" | "notifications" | "preferences" | "privacy" | "accessibility" | "account";

export default function SettingsPage() {
  const router = useRouter();
  const logoutMutation = useLogout();
  const [activeTab, setActiveTab] = useState<TabType>("security");
  const [isSaving, setIsSaving] = useState(false);
  const [auditLogsPage, setAuditLogsPage] = useState(1);
  const [auditLogsFilter, setAuditLogsFilter] = useState<string>("all");
  
  // Sessions
  const { data: sessionsData, isLoading: isLoadingSessions } = useSessions();
  const revokeSessionMutation = useRevokeSession();
  const revokeAllOtherMutation = useRevokeAllOtherSessions();
  const revokeAllMutation = useRevokeAllSessions();

  // Confirmation modals state
  const [showRevokeSessionModal, setShowRevokeSessionModal] = useState(false);
  const [sessionToRevoke, setSessionToRevoke] = useState<string | null>(null);
  const [showRevokeAllOtherModal, setShowRevokeAllOtherModal] = useState(false);
  const [showRevokeAllModal, setShowRevokeAllModal] = useState(false);

  // Password form
  const passwordForm = useForm({
    defaultValues: {
      currentPassword: "",
      newPassword: "",
      confirmPassword: "",
    },
  });

  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [passwordStrength, setPasswordStrength] = useState(0);

  // UI-only state (not connected to backend)
  const [twoFactorSMS, setTwoFactorSMS] = useState(false);
  const [twoFactorTOTP, setTwoFactorTOTP] = useState(false);
  const [emailElectionAnnouncements, setEmailElectionAnnouncements] = useState(true);
  const [emailVotingReminders, setEmailVotingReminders] = useState(true);
  const [emailResultsAvailable, setEmailResultsAvailable] = useState(true);
  const [emailActivitySummaries, setEmailActivitySummaries] = useState(false);
  const [browserNotifications, setBrowserNotifications] = useState(false);
  const [notificationSound, setNotificationSound] = useState(true);
  const [quietHours, setQuietHours] = useState(false);
  const [language, setLanguage] = useState("en");
  const [dateFormat, setDateFormat] = useState("MM/DD/YYYY");
  const [timeFormat, setTimeFormat] = useState("12-hour");
  const [timezone, setTimezone] = useState("America/Chicago");
  const [votingAutoSubmit, setVotingAutoSubmit] = useState(false);
  const [votingShowConfirmation, setVotingShowConfirmation] = useState(true);
  const [votingShowPreview, setVotingShowPreview] = useState(true);
  const [showProfile, setShowProfile] = useState(true);
  const [showInCandidates, setShowInCandidates] = useState(true);
  const [showContact, setShowContact] = useState(false);
  const [showPhoto, setShowPhoto] = useState(true);
  const [shareAnalytics, setShareAnalytics] = useState(false);
  const [sharePhotoInResults, setSharePhotoInResults] = useState(true);
  const [fontSize, setFontSize] = useState("medium");
  const [highContrast, setHighContrast] = useState(false);
  const [reduceAnimations, setReduceAnimations] = useState(false);
  const [focusIndicators, setFocusIndicators] = useState(true);
  const [keyboardShortcuts, setKeyboardShortcuts] = useState(false);

  const calculatePasswordStrength = (password: string) => {
    let strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
    if (/\d/.test(password)) strength++;
    if (/[^a-zA-Z\d]/.test(password)) strength++;
    return Math.min(strength, 4);
  };

  const handlePasswordSubmit = async (data: {
    currentPassword: string;
    newPassword: string;
    confirmPassword: string;
  }) => {
    if (data.newPassword !== data.confirmPassword) {
      passwordForm.setError("confirmPassword", {
        message: "Passwords do not match",
      });
      return;
    }

    setIsSaving(true);
    try {
      const response = await api.post("/students/me/change-password", {
        current_password: data.currentPassword,
        new_password: data.newPassword,
        new_password_confirmation: data.confirmPassword,
      });

      if (response.data.success) {
        toast.success("Password changed successfully!");
        passwordForm.reset();
        setPasswordStrength(0);
      }
    } catch (error: unknown) {
      let errorMessage = "Failed to change password. Please try again.";
      if (error && typeof error === "object" && "response" in error) {
        const apiError = error as {
          response?: { data?: { message?: string; errors?: Record<string, string | string[]> } };
        };
        if (apiError.response?.data?.message) {
          errorMessage = apiError.response.data.message;
        }
        if (apiError.response?.data?.errors) {
          Object.entries(apiError.response.data.errors).forEach(([field, messages]) => {
            passwordForm.setError(field as "currentPassword" | "newPassword" | "confirmPassword", {
              message: Array.isArray(messages) ? messages[0] : String(messages),
          });
        });
      }
      }
      toast.error(errorMessage);
    } finally {
      setIsSaving(false);
    }
  };

  const tabs = [
    { id: "security" as TabType, label: "Security & Privacy", icon: Shield },
    { id: "notifications" as TabType, label: "Notifications", icon: Bell },
    { id: "preferences" as TabType, label: "Preferences", icon: Palette },
    { id: "privacy" as TabType, label: "Privacy", icon: User },
    { id: "accessibility" as TabType, label: "Accessibility", icon: Accessibility },
    { id: "account" as TabType, label: "Account", icon: FileText },
  ];

  const ToggleSwitch = ({
    enabled,
    onChange,
  }: {
    enabled: boolean;
    onChange: (enabled: boolean) => void;
  }) => {
  return (
      <button
        type="button"
        onClick={() => onChange(!enabled)}
        className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
          enabled ? "bg-black" : "bg-gray-300"
        }`}
      >
        <span
          className={`inline-block h-4 w-4 transform rounded-full bg-white shadow transition-transform ${
            enabled ? "translate-x-6" : "translate-x-1"
          }`}
        />
      </button>
    );
  };

  // Helper function to get icon component
  const getIconComponent = (iconName: string) => {
    const iconMap: Record<string, React.ComponentType<{ className?: string }>> = {
      CheckCircle,
      XCircle,
      Lock,
      User,
      Activity,
      History,
      Mail,
      AlertCircle,
      Eye,
      Trash2,
      LogOut,
      Edit,
    };
    return iconMap[iconName] || History;
  };

  // Helper function to get color classes
  const getColorClasses = (color: string, status: string) => {
    if (status === "failed") {
      return {
        bg: "bg-red-100",
        text: "text-red-600",
        badgeBg: "bg-red-50",
        badgeText: "text-red-700",
      };
    }

    const colorMap: Record<string, { bg: string; text: string; badgeBg: string; badgeText: string }> = {
      green: { bg: "bg-green-100", text: "text-green-600", badgeBg: "bg-green-50", badgeText: "text-green-700" },
      blue: { bg: "bg-blue-100", text: "text-blue-600", badgeBg: "bg-blue-50", badgeText: "text-blue-700" },
      purple: { bg: "bg-purple-100", text: "text-purple-600", badgeBg: "bg-purple-50", badgeText: "text-purple-700" },
      indigo: { bg: "bg-indigo-100", text: "text-indigo-600", badgeBg: "bg-indigo-50", badgeText: "text-indigo-700" },
      yellow: { bg: "bg-yellow-100", text: "text-yellow-600", badgeBg: "bg-yellow-50", badgeText: "text-yellow-700" },
    };

    return colorMap[color] || { bg: "bg-gray-100", text: "text-gray-600", badgeBg: "bg-gray-50", badgeText: "text-gray-700" };
  };

  // Audit logs query
  const auditLogsParams: { page: number; per_page: number; action_type?: string } = {
    page: auditLogsPage,
    per_page: AUDIT_LOGS_PER_PAGE,
  };

  if (auditLogsFilter === "logins") {
    auditLogsParams.action_type = "login";
  } else if (auditLogsFilter === "security") {
    auditLogsParams.action_type = "update";
  }

  const { data: auditLogsData, isLoading: isLoadingAuditLogs } = useAuditLogs(auditLogsParams);

  return (
    <div className="h-full overflow-y-auto bg-gray-50">
      <div className="p-8 max-w-7xl mx-auto">
        {/* Page Title */}
        <h1 className="text-2xl font-semibold text-gray-900 mb-8">Settings</h1>

        {/* Tabs */}
        <div className="border-b border-gray-200 mb-8">
          <nav className="flex gap-8 text-sm overflow-x-auto">
            {tabs.map((tab) => {
              const Icon = tab.icon;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`pb-3 border-b-2 transition-colors whitespace-nowrap flex items-center gap-2 ${
                    activeTab === tab.id
                      ? "border-black font-medium text-gray-900"
                      : "border-transparent text-gray-500 hover:text-gray-700"
                  }`}
                >
                  <Icon className="w-4 h-4" />
                  {tab.label}
                </button>
              );
            })}
          </nav>
              </div>

        {/* Tab Content */}
              <div className="space-y-6">
          {/* Security & Privacy Tab */}
          {activeTab === "security" && (
            <>
              {/* Change Password Section */}
              <div className="flex items-start gap-3">
                <div className="p-2 rounded-full bg-gray-100">
                  <Lock className="w-5 h-5 text-gray-600" />
                </div>
                <div className="flex-1">
                  <h2 className="text-lg font-semibold text-gray-900">Change Password</h2>
                  <p className="text-sm text-gray-500 mb-4">Update your password to keep your account secure</p>

                  <form onSubmit={passwordForm.handleSubmit(handlePasswordSubmit)} className="space-y-5">
                {/* Current Password */}
                <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Current Password
                  </label>
                  <div className="relative">
                    <input
                      {...passwordForm.register("currentPassword", {
                        required: "Current password is required",
                      })}
                      type={showCurrentPassword ? "text" : "password"}
                          className="w-full border border-gray-300 rounded-md px-3 py-2 pr-10 text-gray-900 placeholder:text-gray-400 focus:ring-black focus:border-black focus:outline-none"
                      placeholder="Enter current password"
                    />
                    <button
                      type="button"
                      onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 focus:outline-none"
                          aria-label={showCurrentPassword ? "Hide password" : "Show password"}
                    >
                      {showCurrentPassword ? (
                        <EyeOff className="w-5 h-5" />
                      ) : (
                        <Eye className="w-5 h-5" />
                      )}
                    </button>
                  </div>
                  {passwordForm.formState.errors.currentPassword && (
                        <p className="mt-1 text-sm text-red-600">
                      {passwordForm.formState.errors.currentPassword.message}
                    </p>
                  )}
                </div>

                {/* New Password */}
                <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">New Password</label>
                  <div className="relative">
                    <input
                      {...passwordForm.register("newPassword", {
                        required: "New password is required",
                        minLength: {
                          value: 8,
                          message: "Password must be at least 8 characters",
                        },
                        onChange: (e) => {
                          setPasswordStrength(calculatePasswordStrength(e.target.value));
                        },
                      })}
                      type={showNewPassword ? "text" : "password"}
                          className="w-full border border-gray-300 rounded-md px-3 py-2 pr-10 text-gray-900 placeholder:text-gray-400 focus:ring-black focus:border-black focus:outline-none"
                      placeholder="Enter new password"
                    />
                    <button
                      type="button"
                      onClick={() => setShowNewPassword(!showNewPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 focus:outline-none"
                          aria-label={showNewPassword ? "Hide password" : "Show password"}
                    >
                      {showNewPassword ? (
                        <EyeOff className="w-5 h-5" />
                      ) : (
                        <Eye className="w-5 h-5" />
                      )}
                    </button>
                  </div>
                  {passwordForm.watch("newPassword") && (
                    <div className="mt-2">
                      <div className="flex gap-1 mb-1">
                        {[1, 2, 3, 4].map((level) => (
                          <div
                            key={level}
                            className={`h-1.5 flex-1 rounded-full ${
                              level <= passwordStrength
                                ? passwordStrength <= 2
                                  ? "bg-red-500"
                                  : passwordStrength === 3
                                  ? "bg-yellow-500"
                                  : "bg-green-500"
                                : "bg-gray-200"
                            }`}
                          />
                        ))}
                      </div>
                      <p className="text-xs text-gray-500">
                        {passwordStrength === 0 && "Enter a password"}
                        {passwordStrength === 1 && "Weak password"}
                        {passwordStrength === 2 && "Fair password"}
                        {passwordStrength === 3 && "Good password"}
                        {passwordStrength === 4 && "Strong password"}
                      </p>
                    </div>
                  )}
                  {passwordForm.formState.errors.newPassword && (
                        <p className="mt-1 text-sm text-red-600">
                      {passwordForm.formState.errors.newPassword.message}
                        </p>
                  )}
                </div>

                {/* Confirm Password */}
                <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Confirm Password
                  </label>
                  <div className="relative">
                    <input
                      {...passwordForm.register("confirmPassword", {
                        required: "Please confirm your password",
                      })}
                      type={showConfirmPassword ? "text" : "password"}
                          className="w-full border border-gray-300 rounded-md px-3 py-2 pr-10 text-gray-900 placeholder:text-gray-400 focus:ring-black focus:border-black focus:outline-none"
                      placeholder="Confirm new password"
                    />
                    <button
                      type="button"
                          onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 focus:outline-none"
                          aria-label={showConfirmPassword ? "Hide password" : "Show password"}
                    >
                      {showConfirmPassword ? (
                        <EyeOff className="w-5 h-5" />
                      ) : (
                        <Eye className="w-5 h-5" />
                      )}
                    </button>
                  </div>
                  {passwordForm.watch("newPassword") &&
                    passwordForm.watch("confirmPassword") &&
                    passwordForm.watch("newPassword") === passwordForm.watch("confirmPassword") &&
                    !passwordForm.formState.errors.confirmPassword && (
                      <div className="mt-2 flex items-center gap-1 text-sm text-green-600">
                        <CheckCircle2 className="w-4 h-4" />
                        Passwords match
                      </div>
                    )}
                  {passwordForm.formState.errors.confirmPassword && (
                        <p className="mt-1 text-sm text-red-600">
                      {passwordForm.formState.errors.confirmPassword.message}
                        </p>
                  )}
                </div>

                {/* Save Button */}
                    <button
                    type="submit"
                    disabled={isSaving || passwordForm.formState.isSubmitting}
                      className="px-5 py-2 rounded-md bg-black text-white font-medium hover:bg-gray-900 transition disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {isSaving ? "Saving..." : "Save"}
                    </button>
                  </form>
                </div>
              </div>

              {/* Divider */}
              <div className="border-t border-gray-200 my-8"></div>

              {/* Two-Factor Authentication - COMMENTED OUT */}
              {false && (
                <div>
                  <h2 className="text-lg font-semibold text-gray-900 mb-1">
                    Two-factor authentication (2FA)
                  </h2>
                  <p className="text-sm text-gray-500 mb-4">
                    Keep your account secure by enabling 2FA via SMS or using OTP from authenticator app
                  </p>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                      <div className="flex items-center gap-3">
                        <div className="p-2 bg-gray-100 rounded-md">
                          <Smartphone className="w-5 h-5 text-gray-700" />
                        </div>
                        <div>
                          <p className="font-medium text-gray-900">Text message SMS</p>
                          <p className="text-sm text-gray-500">
                            Receive a one-time passcode each time you log in.
                          </p>
                        </div>
                      </div>
                      <ToggleSwitch enabled={twoFactorSMS} onChange={setTwoFactorSMS} />
                    </div>

                    <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                      <div className="flex items-center gap-3">
                        <div className="p-2 bg-gray-100 rounded-md">
                          <svg
                            className="w-5 h-5 text-gray-700"
                          fill="none"
                            stroke="currentColor"
                          viewBox="0 0 24 24"
                        >
                          <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth="2"
                              d="M12 6v6l4 2m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                          />
                        </svg>
                        </div>
                        <div>
                          <p className="font-medium text-gray-900">Authenticator app (TOTP)</p>
                          <p className="text-sm text-gray-500">
                            Use an app to receive a temporary one-time passcode.
                          </p>
                        </div>
                      </div>
                      <ToggleSwitch enabled={twoFactorTOTP} onChange={setTwoFactorTOTP} />
                    </div>
                  </div>
                </div>
              )}

              {/* Divider */}
              <div className="border-t border-gray-200 my-8"></div>

              {/* Active Sessions */}
              <div>
                <h2 className="text-lg font-semibold text-gray-900 mb-1">Active Sessions</h2>
                <p className="text-sm text-gray-500 mb-4">
                  View and manage your active login sessions across different devices
                </p>

                {isLoadingSessions ? (
                  <div className="border border-gray-200 rounded-xl p-12 text-center">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900 mx-auto"></div>
                    <p className="mt-4 text-sm text-gray-500">Loading sessions...</p>
                  </div>
                ) : sessionsData?.data && sessionsData.data.length > 0 ? (
                  <div className="border border-gray-200 rounded-xl overflow-hidden">
                    <div className="divide-y divide-gray-100">
                      {sessionsData.data.map((session) => (
                        <div
                          key={session.id}
                          className="p-4 hover:bg-gray-50 transition-colors"
                        >
                          <div className="flex items-start justify-between gap-4">
                            <div className="flex-1">
                              <div className="flex items-center gap-2 mb-1">
                                <p className="text-sm font-medium text-gray-900">
                                  {session.is_current ? "Current Session" : "Active Session"}
                                </p>
                                {session.is_current && (
                                  <span className="px-2 py-0.5 text-xs font-medium text-green-700 bg-green-50 rounded-full">
                                    Active
                      </span>
                                )}
                              </div>
                              <div className="flex flex-wrap items-center gap-3 text-xs text-gray-500 mt-1">
                                {session.device_info && (
                                  <span className="flex items-center gap-1">
                                    <Monitor className="w-3 h-3" />
                                    {session.device_info}
                      </span>
                    )}
                                {session.ip_address && (
                                  <span className="flex items-center gap-1">
                                    <Globe className="w-3 h-3" />
                                    {session.ip_address}
                                  </span>
                                )}
                                {session.location && (
                                  <span className="flex items-center gap-1">
                                    <MapPin className="w-3 h-3" />
                                    {session.location}
                                  </span>
                                )}
                                <span className="flex items-center gap-1">
                                  <Clock className="w-3 h-3" />
                                  Last active: {session.last_activity_human}
                                </span>
                              </div>
                            </div>
                            {!session.is_current && (
                    <button
                      onClick={() => {
                                  setSessionToRevoke(session.jti);
                                  setShowRevokeSessionModal(true);
                      }}
                                disabled={revokeSessionMutation.isPending}
                                className="text-sm text-red-600 hover:text-red-700 disabled:opacity-50"
                    >
                                Revoke
                    </button>
                  )}
                </div>
              </div>
                      ))}
          </div>
                    <div className="border-t border-gray-200 p-4 bg-gray-50">
                      <div className="flex items-center justify-between gap-4">
                        <div>
                          <p className="text-sm font-medium text-gray-900">
                            {sessionsData.data.length} active session{sessionsData.data.length !== 1 ? "s" : ""}
                          </p>
                          <p className="text-xs text-gray-500 mt-1">
                            You can log out from other devices to keep your account secure
                          </p>
                        </div>
                        <div className="flex gap-2">
                          <button
                            onClick={() => setShowRevokeAllOtherModal(true)}
                            disabled={revokeAllOtherMutation.isPending}
                            className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                          >
                            {revokeAllOtherMutation.isPending ? "Logging out..." : "Log out from other devices"}
                          </button>
                          <button
                            onClick={() => setShowRevokeAllModal(true)}
                            disabled={revokeAllMutation.isPending}
                            className="px-4 py-2 text-sm font-medium text-red-700 bg-white border border-red-300 rounded-md hover:bg-red-50 disabled:opacity-50 disabled:cursor-not-allowed"
                          >
                            {revokeAllMutation.isPending ? "Logging out..." : "Log out from all devices"}
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="border border-gray-200 rounded-xl p-12 text-center">
                    <Monitor className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                    <p className="text-sm font-medium text-gray-900 mb-1">No active sessions</p>
                    <p className="text-xs text-gray-500">Your active sessions will appear here.</p>
                  </div>
                )}
              </div>

              {/* Divider */}
              <div className="border-t border-gray-200 my-8"></div>

              {/* Audit Logs */}
              <div>
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h2 className="text-lg font-semibold text-gray-900 mb-1">Audit Logs</h2>
                    <p className="text-sm text-gray-500">
                      View your login history, IP addresses, and account activity
                    </p>
                  </div>
                  <button className="text-sm text-gray-600 hover:text-gray-900 flex items-center gap-2">
                    <Download className="w-4 h-4" />
                    Export Logs
                  </button>
                </div>

                {/* Filter Tabs */}
                <div className="flex gap-2 mb-4 border-b border-gray-200">
                  {[
                    { id: "all", label: "All Activity" },
                    { id: "logins", label: "Logins" },
                    { id: "security", label: "Security" },
                    { id: "profile", label: "Profile Changes" },
                  ].map((tab) => (
                    <button
                      key={tab.id}
                      onClick={() => {
                        setAuditLogsFilter(tab.id);
                        setAuditLogsPage(1);
                      }}
                      className={`pb-2 px-3 text-sm font-medium transition-colors border-b-2 ${
                        auditLogsFilter === tab.id
                          ? "text-gray-900 border-black"
                          : "text-gray-600 border-transparent hover:text-gray-900 hover:border-gray-300"
                      }`}
                    >
                      {tab.label}
                    </button>
                  ))}
                </div>

                {/* Audit Logs List */}
                {isLoadingAuditLogs ? (
                  <div className="border border-gray-200 rounded-xl p-12 text-center">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900 mx-auto"></div>
                    <p className="mt-4 text-sm text-gray-500">Loading audit logs...</p>
                  </div>
                ) : auditLogsData?.data && auditLogsData.data.length > 0 ? (
                  <>
                    <div className="border border-gray-200 rounded-xl overflow-hidden">
                      <div className="divide-y divide-gray-100">
                        {auditLogsData.data.map((log: AuditLog) => {
                          const IconComponent = getIconComponent(log.icon);
                          const colors = getColorClasses(log.color, log.status);
                          const deviceInfo = log.browser && log.device ? `${log.browser} on ${log.device}` : log.device || log.browser || "Unknown";

                          return (
                            <div key={log.id} className="p-4 hover:bg-gray-50 transition-colors">
                              <div className="flex items-start gap-3">
                                <div className={`p-2 ${colors.bg} rounded-md`}>
                                  <IconComponent className={`w-4 h-4 ${colors.text}`} />
                                </div>
                                <div className="flex-1 min-w-0">
                                  <div className="flex items-start justify-between gap-4">
                                    <div className="flex-1">
                                      <p className="text-sm font-medium text-gray-900">{log.action_description}</p>
                                      <div className="mt-1 flex flex-wrap items-center gap-3 text-xs text-gray-500">
                                        <span className="flex items-center gap-1">
                                          <Clock className="w-3 h-3" />
                                          {log.created_at_human}
                                        </span>
                                        {log.ip_address && (
                                          <span className="flex items-center gap-1">
                                            <Globe className="w-3 h-3" />
                                            {log.ip_address}
                                          </span>
                                        )}
                                        {deviceInfo !== "Unknown" && (
                                          <span className="flex items-center gap-1">
                                            <Monitor className="w-3 h-3" />
                                            {deviceInfo}
                                          </span>
                                        )}
                                        {log.location && (
                                          <span className="flex items-center gap-1">
                                            <MapPin className="w-3 h-3" />
                                            {log.location}
                                          </span>
                                        )}
                                      </div>
                                      {log.changes_summary && (
                                        <p className="mt-1 text-xs text-gray-600">{log.changes_summary}</p>
                                      )}
                                      {log.error_message && (
                                        <p className="mt-1 text-xs text-red-600">Reason: {log.error_message}</p>
                                      )}
                                    </div>
                                    <span className={`px-2 py-1 text-xs font-medium ${colors.badgeText} ${colors.badgeBg} rounded-full whitespace-nowrap`}>
                                      {log.badge}
                                    </span>
                                  </div>
                                </div>
      </div>
    </div>
  );
                        })}
                      </div>
                    </div>

                    {/* Pagination */}
                    {auditLogsData.meta && (
                      <div className="mt-4 space-y-3">
                        <div className="flex items-center justify-between text-sm text-gray-600">
                          <span>
                            Showing{" "}
                            {auditLogsData.meta.from ?? 0} - {auditLogsData.meta.to ?? auditLogsData.data.length} of{" "}
                            {auditLogsData.meta.total} log{auditLogsData.meta.total === 1 ? "" : "s"}
                          </span>
                          <span>
                            Page {auditLogsData.meta.current_page} of {auditLogsData.meta.last_page}
                          </span>
                        </div>
                        <Pagination
                          currentPage={auditLogsData.meta.current_page}
                          totalPages={auditLogsData.meta.last_page}
                          onPageChange={setAuditLogsPage}
                          itemsPerPage={auditLogsData.meta.per_page || AUDIT_LOGS_PER_PAGE}
                          totalItems={auditLogsData.meta.total}
                        />
                      </div>
                    )}
                  </>
                ) : (
                  <div className="border border-gray-200 rounded-xl p-12 text-center">
                    <History className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                    <p className="text-sm font-medium text-gray-900 mb-1">No audit logs found</p>
                    <p className="text-xs text-gray-500">Your activity will appear here once you start using the system.</p>
                  </div>
                )}

                {/* Summary Stats */}
                {auditLogsData?.statistics && (
                  <div className="mt-6 grid grid-cols-1 md:grid-cols-4 gap-4">
                    <div className="border border-gray-200 rounded-lg p-4">
                      <div className="flex items-center gap-2 mb-1">
                        <CheckCircle className="w-4 h-4 text-green-600" />
                        <p className="text-xs text-gray-500">Successful Logins</p>
                      </div>
                      <p className="text-2xl font-semibold text-gray-900">{auditLogsData.statistics.successful_logins}</p>
                      <p className="text-xs text-gray-500 mt-1">Last 30 days</p>
                    </div>
                    <div className="border border-gray-200 rounded-lg p-4">
                      <div className="flex items-center gap-2 mb-1">
                        <XCircle className="w-4 h-4 text-red-600" />
                        <p className="text-xs text-gray-500">Failed Attempts</p>
                      </div>
                      <p className="text-2xl font-semibold text-gray-900">{auditLogsData.statistics.failed_attempts}</p>
                      <p className="text-xs text-gray-500 mt-1">Last 30 days</p>
                    </div>
                    <div className="border border-gray-200 rounded-lg p-4">
                      <div className="flex items-center gap-2 mb-1">
                        <Globe className="w-4 h-4 text-blue-600" />
                        <p className="text-xs text-gray-500">Unique IPs</p>
                      </div>
                      <p className="text-2xl font-semibold text-gray-900">{auditLogsData.statistics.unique_ips}</p>
                      <p className="text-xs text-gray-500 mt-1">Last 30 days</p>
                    </div>
                    <div className="border border-gray-200 rounded-lg p-4">
                      <div className="flex items-center gap-2 mb-1">
                        <Activity className="w-4 h-4 text-purple-600" />
                        <p className="text-xs text-gray-500">Total Activities</p>
                      </div>
                      <p className="text-2xl font-semibold text-gray-900">{auditLogsData.statistics.total_activities}</p>
                      <p className="text-xs text-gray-500 mt-1">Last 30 days</p>
                    </div>
                  </div>
                )}
              </div>
            </>
          )}

          {/* Notifications Tab */}
          {activeTab === "notifications" && (
            <>
              {/* Email Notifications */}
              <div className="flex items-start gap-3">
                <div className="p-2 rounded-full bg-gray-100">
                  <Bell className="w-5 h-5 text-gray-600" />
                </div>
                <div className="flex-1">
                  <h2 className="text-lg font-semibold text-gray-900">Email Notifications</h2>
                  <p className="text-sm text-gray-500 mb-4">
                    Choose which email notifications you want to receive
                  </p>

                  <div className="space-y-4">
                    <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                      <div className="flex-1">
                        <p className="font-medium text-gray-900">Election Announcements</p>
                        <p className="text-sm text-gray-500 mt-1">
                          Get notified when new elections become available
                        </p>
                      </div>
                      <ToggleSwitch
                        enabled={emailElectionAnnouncements}
                        onChange={setEmailElectionAnnouncements}
                      />
                    </div>

                    <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                      <div className="flex-1">
                        <p className="font-medium text-gray-900">Voting Reminders</p>
                        <p className="text-sm text-gray-500 mt-1">
                          Receive reminders before elections close
                        </p>
                      </div>
                      <ToggleSwitch
                        enabled={emailVotingReminders}
                        onChange={setEmailVotingReminders}
                      />
                    </div>

                    <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                      <div className="flex-1">
                        <p className="font-medium text-gray-900">Results Available</p>
                        <p className="text-sm text-gray-500 mt-1">
                          Get notified when election results are published
                        </p>
                      </div>
                      <ToggleSwitch
                        enabled={emailResultsAvailable}
                        onChange={setEmailResultsAvailable}
                      />
                    </div>

                    <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                      <div className="flex-1">
                        <p className="font-medium text-gray-900">Activity Summaries</p>
                        <p className="text-sm text-gray-500 mt-1">
                          Receive daily or weekly summaries of voting activity
                        </p>
                      </div>
                      <ToggleSwitch
                        enabled={emailActivitySummaries}
                        onChange={setEmailActivitySummaries}
                      />
                    </div>
                  </div>
                </div>
              </div>

              {/* Divider */}
              <div className="border-t border-gray-200 my-8"></div>

              {/* In-App Notifications */}
              <div>
                <h2 className="text-lg font-semibold text-gray-900 mb-1">In-App Notifications</h2>
                <p className="text-sm text-gray-500 mb-4">
                  Control browser and in-app notification settings
                </p>

                <div className="space-y-4">
                  <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">Browser Notifications</p>
                      <p className="text-sm text-gray-500 mt-1">
                        Enable push notifications in your browser
                      </p>
                    </div>
                    <ToggleSwitch
                      enabled={browserNotifications}
                      onChange={setBrowserNotifications}
                    />
                  </div>

                  <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">Notification Sound</p>
                      <p className="text-sm text-gray-500 mt-1">
                        Play a sound when notifications arrive
                      </p>
                    </div>
                    <ToggleSwitch enabled={notificationSound} onChange={setNotificationSound} />
                  </div>

                  <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">Quiet Hours</p>
                      <p className="text-sm text-gray-500 mt-1">
                        Disable notifications during specific hours
                      </p>
                    </div>
                    <ToggleSwitch enabled={quietHours} onChange={setQuietHours} />
                  </div>
                </div>
              </div>
            </>
          )}

          {/* Preferences Tab */}
          {activeTab === "preferences" && (
            <>
              {/* Language & Region */}
              <div>
                <h2 className="text-lg font-semibold text-gray-900 mb-1">Language & Region</h2>
                <p className="text-sm text-gray-500 mb-4">Set your language, date, and time preferences</p>

                <div className="space-y-5">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Language</label>
                    <select
                      value={language}
                      onChange={(e) => setLanguage(e.target.value)}
                      className="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-black focus:border-black text-gray-900 bg-white"
                    >
                      <option value="en">English</option>
                      <option value="es">Spanish</option>
                      <option value="fr">French</option>
                      <option value="de">German</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Date Format</label>
                    <select
                      value={dateFormat}
                      onChange={(e) => setDateFormat(e.target.value)}
                      className="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-black focus:border-black text-gray-900 bg-white"
                    >
                      <option value="MM/DD/YYYY">MM/DD/YYYY</option>
                      <option value="DD/MM/YYYY">DD/MM/YYYY</option>
                      <option value="YYYY-MM-DD">YYYY-MM-DD</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Time Format</label>
                    <div className="grid grid-cols-2 gap-4">
                      {[
                        { value: "12-hour", label: "12-hour (3:45 PM)" },
                        { value: "24-hour", label: "24-hour (15:45)" },
                      ].map((option) => (
                        <button
                          key={option.value}
                          onClick={() => setTimeFormat(option.value)}
                          className={`p-3 border-2 rounded-lg text-left transition ${
                            timeFormat === option.value
                              ? "border-black bg-gray-50"
                              : "border-gray-200 hover:border-gray-300"
                          }`}
                        >
                          <p
                            className={`text-sm font-medium ${
                              timeFormat === option.value ? "text-gray-900" : "text-gray-700"
                            }`}
                          >
                            {option.label}
                          </p>
                        </button>
                      ))}
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Timezone</label>
                    <select
                      value={timezone}
                      onChange={(e) => setTimezone(e.target.value)}
                      className="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-black focus:border-black text-gray-900 bg-white"
                    >
                      <option value="America/Chicago">Central Time (America/Chicago)</option>
                      <option value="America/New_York">Eastern Time (America/New_York)</option>
                      <option value="America/Denver">Mountain Time (America/Denver)</option>
                      <option value="America/Los_Angeles">Pacific Time (America/Los_Angeles)</option>
                      <option value="America/Phoenix">Arizona Time (America/Phoenix)</option>
                      <option value="America/Anchorage">Alaska Time (America/Anchorage)</option>
                      <option value="Pacific/Honolulu">Hawaii Time (Pacific/Honolulu)</option>
                      <option value="UTC">UTC (Coordinated Universal Time)</option>
                    </select>
                  </div>
                </div>
              </div>

              {/* Divider */}
              <div className="border-t border-gray-200 my-8"></div>

              {/* Voting Preferences */}
              <div>
                <h2 className="text-lg font-semibold text-gray-900 mb-1">Voting Preferences</h2>
                <p className="text-sm text-gray-500 mb-4">Customize your voting experience</p>

                <div className="space-y-4">
                  <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">Auto-submit on Final Selection</p>
                      <p className="text-sm text-gray-500 mt-1">
                        Automatically submit vote when all positions are selected
                      </p>
                    </div>
                    <ToggleSwitch enabled={votingAutoSubmit} onChange={setVotingAutoSubmit} />
                  </div>

                  <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">Show Confirmation Dialog</p>
                      <p className="text-sm text-gray-500 mt-1">
                        Show a confirmation dialog before submitting your vote
                      </p>
                    </div>
                    <ToggleSwitch
                      enabled={votingShowConfirmation}
                      onChange={setVotingShowConfirmation}
                    />
                  </div>

                  <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">Show Vote Preview</p>
                      <p className="text-sm text-gray-500 mt-1">
                        Display a preview of your selections before submitting
                      </p>
                    </div>
                    <ToggleSwitch enabled={votingShowPreview} onChange={setVotingShowPreview} />
                  </div>
                </div>
              </div>
            </>
          )}

          {/* Privacy Tab */}
          {activeTab === "privacy" && (
            <>
              {/* Profile Visibility */}
              <div className="flex items-start gap-3">
                <div className="p-2 rounded-full bg-gray-100">
                  <User className="w-5 h-5 text-gray-600" />
                </div>
                <div className="flex-1">
                  <h2 className="text-lg font-semibold text-gray-900">Profile Visibility</h2>
                  <p className="text-sm text-gray-500 mb-4">
                    Control who can see your profile information
                  </p>

                  <div className="space-y-4">
                    <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                      <div className="flex-1">
                        <p className="font-medium text-gray-900">Show Profile to Other Students</p>
                        <p className="text-sm text-gray-500 mt-1">
                          Allow other students to view your profile
                        </p>
                      </div>
                      <ToggleSwitch enabled={showProfile} onChange={setShowProfile} />
                    </div>

                    <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                      <div className="flex-1">
                        <p className="font-medium text-gray-900">Show in Candidate Listings</p>
                        <p className="text-sm text-gray-500 mt-1">
                          Display your profile when running as a candidate
                        </p>
                      </div>
                      <ToggleSwitch enabled={showInCandidates} onChange={setShowInCandidates} />
                    </div>

                    <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                      <div className="flex-1">
                        <p className="font-medium text-gray-900">Show Contact Information</p>
                        <p className="text-sm text-gray-500 mt-1">
                          Allow others to see your contact details
                        </p>
                      </div>
                      <ToggleSwitch enabled={showContact} onChange={setShowContact} />
                    </div>

                    <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                      <div className="flex-1">
                        <p className="font-medium text-gray-900">Show Profile Photo Publicly</p>
                        <p className="text-sm text-gray-500 mt-1">
                          Display your profile photo in public areas
                        </p>
                      </div>
                      <ToggleSwitch enabled={showPhoto} onChange={setShowPhoto} />
                    </div>
                  </div>
                </div>
              </div>

              {/* Divider */}
              <div className="border-t border-gray-200 my-8"></div>

              {/* Data Sharing */}
              <div>
                <h2 className="text-lg font-semibold text-gray-900 mb-1">Data Sharing</h2>
                <p className="text-sm text-gray-500 mb-4">Control how your data is shared and used</p>

                <div className="space-y-4">
                  <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">Share Analytics Data</p>
                      <p className="text-sm text-gray-500 mt-1">
                        Help improve the platform by sharing anonymous usage data
                      </p>
                    </div>
                    <ToggleSwitch enabled={shareAnalytics} onChange={setShareAnalytics} />
                  </div>

                  <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">Allow Profile Photo in Results</p>
                      <p className="text-sm text-gray-500 mt-1">
                        Display your photo in election results (if applicable)
                      </p>
                    </div>
                    <ToggleSwitch
                      enabled={sharePhotoInResults}
                      onChange={setSharePhotoInResults}
                    />
                  </div>
                </div>
              </div>
            </>
          )}

          {/* Accessibility Tab */}
          {activeTab === "accessibility" && (
            <>
              {/* Display Options */}
              <div className="flex items-start gap-3">
                <div className="p-2 rounded-full bg-gray-100">
                  <Accessibility className="w-5 h-5 text-gray-600" />
                </div>
                <div className="flex-1">
                  <h2 className="text-lg font-semibold text-gray-900">Display Options</h2>
                  <p className="text-sm text-gray-500 mb-4">
                    Customize display settings for better accessibility
                  </p>

                  <div className="space-y-5">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Font Size
                      </label>
                      <select
                        value={fontSize}
                        onChange={(e) => setFontSize(e.target.value)}
                        className="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-black focus:border-black"
                      >
                        <option value="small">Small</option>
                        <option value="medium">Medium</option>
                        <option value="large">Large</option>
                        <option value="extra-large">Extra Large</option>
                      </select>
                    </div>
                  </div>
                </div>
              </div>

              {/* Divider */}
              <div className="border-t border-gray-200 my-8"></div>

              {/* Accessibility Features */}
              <div>
                <h2 className="text-lg font-semibold text-gray-900 mb-1">Accessibility Features</h2>
                <p className="text-sm text-gray-500 mb-4">Enable features to improve accessibility</p>

                <div className="space-y-4">
                  <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">High Contrast Mode</p>
                      <p className="text-sm text-gray-500 mt-1">Increase contrast for better visibility</p>
                    </div>
                    <ToggleSwitch enabled={highContrast} onChange={setHighContrast} />
                  </div>

                  <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">Reduce Animations</p>
                      <p className="text-sm text-gray-500 mt-1">Minimize motion and animations</p>
                    </div>
                    <ToggleSwitch enabled={reduceAnimations} onChange={setReduceAnimations} />
                  </div>

                  <div className="flex justify-between items-center border border-gray-200 rounded-xl p-4">
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">Enhanced Focus Indicators</p>
                      <p className="text-sm text-gray-500 mt-1">
                        Show clearer focus indicators for keyboard navigation
                      </p>
                    </div>
                    <ToggleSwitch enabled={focusIndicators} onChange={setFocusIndicators} />
                  </div>
                </div>
              </div>

              {/* Divider */}
              <div className="border-t border-gray-200 my-8"></div>

              {/* Keyboard Navigation */}
              <div>
                <h2 className="text-lg font-semibold text-gray-900 mb-1">Keyboard Navigation</h2>
                <p className="text-sm text-gray-500 mb-4">
                  Enable and configure keyboard shortcuts
                </p>

                <div className="border border-gray-200 rounded-xl p-4">
                  <div className="flex justify-between items-center mb-4">
                    <div>
                      <p className="font-medium text-gray-900">Enable Keyboard Shortcuts</p>
                      <p className="text-sm text-gray-500 mt-1">
                        Use keyboard shortcuts for faster navigation
                      </p>
                    </div>
                    <ToggleSwitch
                      enabled={keyboardShortcuts}
                      onChange={setKeyboardShortcuts}
                    />
                  </div>

                  {keyboardShortcuts && (
                    <div className="mt-4 pt-4 border-t border-gray-200">
                      <p className="text-sm font-medium text-gray-900 mb-3">Common Shortcuts:</p>
                      <div className="space-y-2 text-sm text-gray-600">
                        <div className="flex justify-between items-center">
                          <span>Show shortcuts</span>
                          <kbd className="px-2 py-1 bg-gray-100 rounded text-xs font-mono">?</kbd>
                        </div>
                        <div className="flex justify-between items-center">
                          <span>Go to Dashboard</span>
                          <kbd className="px-2 py-1 bg-gray-100 rounded text-xs font-mono">G D</kbd>
                        </div>
                        <div className="flex justify-between items-center">
                          <span>Go to Vote</span>
                          <kbd className="px-2 py-1 bg-gray-100 rounded text-xs font-mono">G V</kbd>
                        </div>
                        <div className="flex justify-between items-center">
                          <span>Go to Results</span>
                          <kbd className="px-2 py-1 bg-gray-100 rounded text-xs font-mono">G R</kbd>
                        </div>
                        <div className="flex justify-between items-center">
                          <span>Go to Profile</span>
                          <kbd className="px-2 py-1 bg-gray-100 rounded text-xs font-mono">G P</kbd>
                        </div>
                        <div className="flex justify-between items-center">
                          <span>Go to Settings</span>
                          <kbd className="px-2 py-1 bg-gray-100 rounded text-xs font-mono">G S</kbd>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </>
          )}

          {/* Account Tab */}
          {activeTab === "account" && (
            <>
              {/* Data Export */}
              <div className="flex items-start gap-3">
                <div className="p-2 rounded-full bg-gray-100">
                  <FileText className="w-5 h-5 text-gray-600" />
                </div>
                <div className="flex-1">
                  <h2 className="text-lg font-semibold text-gray-900">Data Export</h2>
                  <p className="text-sm text-gray-500 mb-4">
                    Download your account data or request account deletion
                  </p>

                  <div className="space-y-4">
                    <div className="border border-gray-200 rounded-xl p-4">
                      <div className="flex justify-between items-center">
                        <div className="flex items-center gap-3">
                          <div className="p-2 bg-gray-100 rounded-md">
                            <Download className="w-5 h-5 text-gray-700" />
                          </div>
                          <div>
                            <p className="font-medium text-gray-900">Download My Data</p>
                            <p className="text-sm text-gray-500 mt-1">
                              Export your account data in JSON or CSV format
                            </p>
                          </div>
                        </div>
                        <button className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">
                          Download
                        </button>
                      </div>
                    </div>

                    <div className="border border-gray-200 rounded-xl p-4">
                      <div className="flex justify-between items-center">
                        <div className="flex items-center gap-3">
                          <div className="p-2 bg-gray-100 rounded-md">
                            <Trash2 className="w-5 h-5 text-gray-700" />
                          </div>
                          <div>
                            <p className="font-medium text-gray-900">Request Account Deletion</p>
                            <p className="text-sm text-gray-500 mt-1">
                              Permanently delete your account and all associated data
                            </p>
                          </div>
                        </div>
                        <button className="px-4 py-2 border border-red-300 rounded-md text-sm font-medium text-red-700 hover:bg-red-50">
                          Request Deletion
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Divider */}
              <div className="border-t border-gray-200 my-8"></div>

              {/* Help & Support */}
              <div>
                <h2 className="text-lg font-semibold text-gray-900 mb-1">Help & Support</h2>
                <p className="text-sm text-gray-500 mb-4">
                  Get help, contact support, and access documentation
                </p>

                <div className="space-y-4">
                  {[
                    {
                      id: "contactSupport",
                      label: "Contact Support",
                      description: "Get in touch with our support team",
                      action: "Send Email",
                      href: "mailto:support@fisk.edu",
                      icon: Mail,
                    },
                    {
                      id: "reportBug",
                      label: "Report a Bug",
                      description: "Found an issue? Let us know",
                      action: "Report",
                      href: "mailto:bugs@fisk.edu?subject=Bug Report",
                      icon: MessageCircle,
                    },
                    {
                      id: "featureRequest",
                      label: "Feature Request",
                      description: "Have an idea for a new feature?",
                      action: "Request",
                      href: "mailto:features@fisk.edu?subject=Feature Request",
                      icon: MessageCircle,
                    },
                    {
                      id: "privacyPolicy",
                      label: "Privacy Policy",
                      description: "Read our privacy policy",
                      action: "View",
                      href: "#",
                      icon: FileText,
                    },
                    {
                      id: "termsOfService",
                      label: "Terms of Service",
                      description: "Review terms and conditions",
                      action: "View",
                      href: "#",
                      icon: FileText,
                    },
                  ].map((item) => {
                    const Icon = item.icon;
                    return (
                      <div
                        key={item.id}
                        className="flex justify-between items-center border border-gray-200 rounded-xl p-4"
                      >
                        <div className="flex items-center gap-3 flex-1">
                          <div className="p-2 bg-gray-100 rounded-md">
                            <Icon className="w-5 h-5 text-gray-700" />
                          </div>
                          <div>
                            <p className="font-medium text-gray-900">{item.label}</p>
                            <p className="text-sm text-gray-500 mt-1">{item.description}</p>
                          </div>
                        </div>
                        {item.href.startsWith("mailto:") ? (
                          <a
                            href={item.href}
                            className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 inline-flex items-center gap-2"
                          >
                            {item.action}
                            <ExternalLink className="w-4 h-4" />
                          </a>
                        ) : (
                          <button
                            disabled
                            className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-400 cursor-not-allowed"
                          >
                            {item.action} (Soon)
                          </button>
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>
            </>
          )}
        </div>
      </div>

      {/* Confirmation Modals */}
      <ConfirmationModal
        isOpen={showRevokeSessionModal}
        onClose={() => {
          setShowRevokeSessionModal(false);
          setSessionToRevoke(null);
        }}
        onConfirm={async () => {
          if (sessionToRevoke) {
            try {
              await revokeSessionMutation.mutateAsync(sessionToRevoke);
              toast.success("Session revoked successfully");
              setShowRevokeSessionModal(false);
              setSessionToRevoke(null);
            } catch (error) {
              toast.error("Failed to revoke session");
            }
          }
        }}
        title="Revoke Session"
        message="Are you sure you want to log out from this device? This action cannot be undone."
        confirmText="Revoke Session"
        cancelText="Cancel"
        variant="warning"
        isLoading={revokeSessionMutation.isPending}
      />

      <ConfirmationModal
        isOpen={showRevokeAllOtherModal}
        onClose={() => setShowRevokeAllOtherModal(false)}
        onConfirm={async () => {
          try {
            await revokeAllOtherMutation.mutateAsync();
            toast.success("Logged out from all other devices");
            setShowRevokeAllOtherModal(false);
          } catch (error) {
            toast.error("Failed to log out from other devices");
          }
        }}
        title="Log Out from Other Devices"
        message="Are you sure you want to log out from all other devices? You will remain logged in on this device."
        confirmText="Log Out from Other Devices"
        cancelText="Cancel"
        variant="warning"
        isLoading={revokeAllOtherMutation.isPending}
      />

      <ConfirmationModal
        isOpen={showRevokeAllModal}
        onClose={() => setShowRevokeAllModal(false)}
        onConfirm={async () => {
          try {
            await revokeAllMutation.mutateAsync();
            toast.success("Logged out from all devices");
            setShowRevokeAllModal(false);
            // Logout and redirect to login
            await logoutMutation.mutateAsync();
            router.replace("/login");
          } catch (error) {
            toast.error("Failed to log out from all devices");
          }
        }}
        title="Log Out from All Devices"
        message="Are you sure you want to log out from ALL devices? You will need to log in again on all devices."
        confirmText="Log Out from All Devices"
        cancelText="Cancel"
        variant="danger"
        isLoading={revokeAllMutation.isPending || logoutMutation.isPending}
      />
    </div>
  );
}
