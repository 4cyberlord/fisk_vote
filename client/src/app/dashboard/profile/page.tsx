"use client";

import { useAuth, useCurrentUser } from "@/hooks/useAuth";
import { useState, useMemo, useRef, useEffect } from "react";
import { Button } from "@/components";
import { useForm } from "react-hook-form";
import { api } from "@/lib/axios";
import { useQueryClient } from "@tanstack/react-query";
import toast from "react-hot-toast";
import Avatar, { genConfig } from "react-nice-avatar";
// import { useVotingStats } from "@/hooks/useElections"; // ARCHIVED
import Link from "next/link";
import { Vote, TrendingUp, Award, History, Calendar, CheckCircle } from "lucide-react";

// Helper to resolve image URLs (handles relative paths from backend)
const BACKEND_URL = process.env.NEXT_PUBLIC_BACKEND_URL || "http://localhost:8000";

function getImageUrl(url: string | null | undefined): string | null {
  if (!url) return null;
  // Already absolute URL
  if (url.startsWith("http://") || url.startsWith("https://")) {
    return url;
  }
  // Relative path - prepend backend URL
  if (url.startsWith("/")) {
    return `${BACKEND_URL}${url}`;
  }
  return `${BACKEND_URL}/${url}`;
}

// Format phone number to use dashes (e.g., 385-446-1000)
function formatPhoneNumber(phone: string | null | undefined): string {
  if (!phone) return "";
  // Remove all non-digit characters
  const digits = phone.replace(/\D/g, "");
  // Format as XXX-XXX-XXXX for 10 digits
  if (digits.length === 10) {
    return `${digits.slice(0, 3)}-${digits.slice(3, 6)}-${digits.slice(6)}`;
  }
  // Format as X-XXX-XXX-XXXX for 11 digits (with country code)
  if (digits.length === 11) {
    return `${digits.slice(0, 1)}-${digits.slice(1, 4)}-${digits.slice(4, 7)}-${digits.slice(7)}`;
  }
  // Otherwise just replace dots/spaces with dashes
  return phone.replace(/[.\s]/g, "-");
}

export default function ProfilePage() {
  const { user: storeUser } = useAuth();
  const { data: currentUserData, isLoading } = useCurrentUser();
  // const { data: votingStats, isLoading: isLoadingStats } = useVotingStats(); // ARCHIVED
  const [isSaving, setIsSaving] = useState(false);
  const [showProfilePhoto, setShowProfilePhoto] = useState(true);
  const [showOrganizations, setShowOrganizations] = useState(true);
  const [dragActive, setDragActive] = useState(false);
  const [isUploadingPhoto, setIsUploadingPhoto] = useState(false);
  const fileInputRef = useRef<HTMLInputElement | null>(null);
  const queryClient = useQueryClient();

  // Get user from API response or fallback to store user
  const apiUser = currentUserData?.data;
  const user = apiUser || storeUser;

  // Form for profile information
  const profileForm = useForm({
    defaultValues: {
      studentId: "",
      universityEmailAlt: "",
      fiskEmail: "",
      personalEmail: "",
      phoneNumber: "",
      address: "",
      department: "",
      major: "",
      classLevel: "",
      studentType: "",
      citizenshipStatus: "",
      organizations: "",
    },
  });

  // Reset form when user data loads
  useEffect(() => {
    if (user) {
      profileForm.reset({
        studentId: user.student_id || "",
        universityEmailAlt: user.university_email || "",
        fiskEmail: user.email || "",
        personalEmail: user.personal_email || "",
        phoneNumber: formatPhoneNumber(user.phone_number),
        address: user.address || "",
        department: user.department || "",
        major: user.major || "",
        classLevel: user.class_level || "",
        studentType: user.student_type || "",
        citizenshipStatus: user.citizenship_status || "",
        organizations: Array.isArray((user as any).organizations) 
          ? (user as any).organizations.map((org: any) => org.name || org).join(", ")
          : "",
      });
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user]);


  const handleProfileSubmit = async (data: any) => {
    setIsSaving(true);
    try {
      const updateData: any = {};
      
      if (data.personalEmail) updateData.personal_email = data.personalEmail;
      if (data.phoneNumber) updateData.phone_number = data.phoneNumber.replace(/-/g, "");
      if (data.address) updateData.address = data.address;
      if (data.department) updateData.department = data.department;
      if (data.major) updateData.major = data.major;
      if (data.classLevel) updateData.class_level = data.classLevel;
      if (data.studentType) updateData.student_type = data.studentType;
      if (data.citizenshipStatus) updateData.citizenship_status = data.citizenshipStatus;

      await api.put("/students/me", updateData);
      
      // Refresh user data
      await queryClient.invalidateQueries({ queryKey: ["user", "current"] });
      
      toast.success("Profile updated successfully!");
    } catch (error: any) {
      const message = error?.response?.data?.message || "Failed to update profile";
      toast.error(message);
    } finally {
      setIsSaving(false);
    }
  };
  const handleDrag = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === "dragenter" || e.type === "dragover") {
      setDragActive(true);
    } else if (e.type === "dragleave") {
      setDragActive(false);
    }
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      void uploadProfilePhoto(e.dataTransfer.files[0]);
    }
  };

  // Get user initials for avatar
  const getUserInitials = () => {
    if (user?.first_name && user?.last_name) {
      return `${user.first_name[0]}${user.last_name[0]}`.toUpperCase();
    }
    if (user?.name) {
      return user.name.substring(0, 2).toUpperCase();
    }
    return "U";
  };

  // Nice avatar config (used when no profile photo exists)
  const avatarConfig = useMemo(() => {
    const seed =
      user?.email ||
      user?.university_email ||
      user?.student_id ||
      user?.name ||
      "student";
    return genConfig(seed);
  }, [user]);

  const uploadProfilePhoto = async (file: File) => {
    try {
      setIsUploadingPhoto(true);

      const formData = new FormData();
      formData.append("profile_photo", file);

      await api.post("/students/me/profile-photo", formData, {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      });

      // Refresh current user data so the new photo is visible
      await queryClient.invalidateQueries({ queryKey: ["user", "current"] });

      toast.success("Profile photo updated successfully.");
    } catch (error: any) {
      // Get specific validation error or fallback message
      const errors = error?.response?.data?.errors;
      const validationError = errors?.profile_photo?.[0];
      const generalMessage = error?.response?.data?.message;
      
      // Log full error details for debugging
      console.error("Profile photo upload error:", JSON.stringify(error?.response?.data, null, 2));
      
      let message = "Failed to upload profile photo. Please try again.";
      if (validationError) {
        message = validationError;
      } else if (errors && Object.keys(errors).length > 0) {
        // Get first error from any field
        const firstErrorKey = Object.keys(errors)[0];
        message = errors[firstErrorKey]?.[0] || message;
      } else if (generalMessage && generalMessage !== "Validation failed.") {
        message = generalMessage;
      }
      
      toast.error(message);
    } finally {
      setIsUploadingPhoto(false);
      setDragActive(false);
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    
    // Client-side validation
    const allowedTypes = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"];
    const maxSize = 2 * 1024 * 1024; // 2MB (PHP default limit)
    
    if (!allowedTypes.includes(file.type)) {
      toast.error("Please upload a JPEG, PNG, GIF, or WebP image.");
      e.target.value = "";
      return;
    }
    
    if (file.size > maxSize) {
      toast.error(`Image must be smaller than 2MB. Your file is ${(file.size / 1024 / 1024).toFixed(1)}MB.`);
      e.target.value = "";
      return;
    }
    
    void uploadProfilePhoto(file);
    // Reset input so the same file can be selected again if needed
    e.target.value = "";
  };

  if (isLoading) {
    return (
      <div className="p-8 flex items-center justify-center min-h-[500px]">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
      </div>
    );
  }

  return (
    <div className="h-full overflow-y-auto bg-gray-50">
      <div className="p-8 max-w-7xl mx-auto">
        <form onSubmit={profileForm.handleSubmit(handleProfileSubmit)}>
          {/* Profile Photo Section */}
          <div className="bg-white border border-gray-200 rounded-lg shadow-sm mb-6">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h2 className="text-xl font-bold text-gray-900">Profile Photo</h2>
                  <p className="text-sm text-gray-600 mt-1">
                    Update your profile picture or we&apos;ll show a generated avatar.
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => setShowProfilePhoto(!showProfilePhoto)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <svg
                    className={`w-5 h-5 transition-transform ${showProfilePhoto ? "rotate-180" : ""}`}
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M5 15l7-7 7 7"
                    />
                  </svg>
                </button>
              </div>

              {showProfilePhoto && (
                <div className="space-y-6">
                  {/* Current Profile Image / Avatar */}
                  <div className="flex items-center gap-4">
                    <div className="h-20 w-20 rounded-full overflow-hidden bg-indigo-600 flex items-center justify-center text-white">
                      {user?.profile_photo ? (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img
                          src={getImageUrl(user.profile_photo) || ""}
                          alt={user.name || "Profile photo"}
                          className="h-20 w-20 object-cover"
                          loading="lazy"
                        />
                      ) : (
                        <Avatar
                          className="w-20 h-20"
                          {...avatarConfig}
                        />
                      )}
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-900">
                        {user?.name || "Student"}
                      </p>
                      <p className="text-xs text-gray-500">
                        This is the photo other students will see in elections and votes.
                      </p>
                    </div>
                  </div>

                  {/* Upload Area */}
                  <div
                    className={`border-2 border-dashed rounded-lg p-8 text-center transition-colors ${
                      dragActive
                        ? "border-indigo-500 bg-indigo-50"
                        : "border-gray-300 bg-gray-50"
                    }`}
                    onDragEnter={handleDrag}
                    onDragLeave={handleDrag}
                    onDragOver={handleDrag}
                    onDrop={handleDrop}
                  >
                    <p className="text-gray-600 mb-2">
                      Drag & drop an image here, or{" "}
                      <button
                        type="button"
                        className="text-indigo-600 hover:text-indigo-700 font-medium"
                        onClick={() => fileInputRef.current?.click()}
                        disabled={isUploadingPhoto}
                      >
                        browse files
                      </button>
                    </p>
                    <p className="text-xs text-gray-500">
                      JPG, PNG or SVG. Maximum size 5MB.
                    </p>
                    <input
                      ref={fileInputRef}
                      type="file"
                      accept="image/jpeg,image/jpg,image/png,image/svg+xml"
                      className="hidden"
                      onChange={handleFileChange}
                    />
                    {isUploadingPhoto && (
                      <p className="mt-2 text-xs text-indigo-600">
                        Uploading photo...
                      </p>
                    )}
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Voting Activity Section - ARCHIVED */}
          {/* <div className="bg-white border border-gray-200 rounded-lg shadow-sm mb-6">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-xl font-bold text-gray-900">Voting Activity</h2>
                <Link
                  href="/dashboard/vote/history"
                  className="text-sm font-medium text-indigo-600 hover:text-indigo-700"
                >
                  View History
                </Link>
              </div>

              {isLoadingStats ? (
                <div className="flex items-center justify-center py-8">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
                </div>
              ) : votingStats ? (
                <>
                  <div className="grid grid-cols-3 gap-4 mb-6">
                    <div className="text-center">
                      <div className="flex items-center justify-center gap-2 mb-2">
                        <Vote className="w-5 h-5 text-indigo-600" />
                        <p className="text-2xl font-bold text-gray-900">
                          {votingStats.elections_voted || 0}
                        </p>
                      </div>
                      <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">
                        Elections Voted
                      </p>
                    </div>
                    <div className="text-center">
                      <div className="flex items-center justify-center gap-2 mb-2">
                        <Award className="w-5 h-5 text-indigo-600" />
                        <p className="text-2xl font-bold text-indigo-600">
                          #{votingStats.campus_rank || 0}
                        </p>
                      </div>
                      <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">
                        Campus Rank
                      </p>
                    </div>
                    <div className="text-center">
                      <div className="flex items-center justify-center gap-2 mb-2">
                        <TrendingUp className="w-5 h-5 text-indigo-600" />
                        <p className="text-2xl font-bold text-gray-900">
                          {votingStats.percentile?.toFixed(1) || "0.0"}%
                        </p>
                      </div>
                      <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">
                        Percentile
                      </p>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <p className="text-sm font-semibold text-gray-900">
                        Campus Impact Score
                      </p>
                      <p className="text-sm font-bold text-indigo-600">
                        {votingStats.impact_score && votingStats.impact_score > 0
                          ? `${votingStats.impact_score}/200`
                          : `${Math.round(votingStats.campus_impact_score || 0)}%`}
                      </p>
                    </div>
                    <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-indigo-600 transition-all duration-600 ease-out rounded-full"
                        style={{
                          width: `${Math.min(
                            (votingStats.campus_impact_score || 0) / 100,
                            1
                          ) * 100}%`,
                        }}
                      />
                    </div>
                    {votingStats.impact_description && (
                      <p className="text-xs text-gray-500 italic mt-1">
                        {votingStats.impact_description}
                      </p>
                    )}
                  </div>
                </>
              ) : (
                <p className="text-sm text-gray-500 text-center py-4">
                  No voting statistics available yet.
                </p>
              )}
            </div>
          </div> */}

          {/* Voting History Section */}
          <div className="bg-white border border-gray-200 rounded-lg shadow-sm mb-6">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className="p-2 bg-indigo-100 rounded-lg">
                    <History className="w-6 h-6 text-indigo-600" />
                  </div>
                  <div>
                    <h2 className="text-xl font-bold text-gray-900">
                      Voting History
                    </h2>
                    <p className="text-sm text-gray-500">
                      Track record of all elections you've participated in
                    </p>
                  </div>
                </div>
              </div>

              <Link
                href="/dashboard/vote/history"
                className="block w-full"
              >
                <div className="flex items-center justify-between p-4 bg-indigo-50 hover:bg-indigo-100 rounded-lg transition-colors duration-200 cursor-pointer border border-indigo-200">
                  <div className="flex items-center gap-3">
                    <div className="p-2 bg-white rounded-lg">
                      <Calendar className="w-5 h-5 text-indigo-600" />
                    </div>
                    <div>
                      <p className="font-semibold text-gray-900">
                        My Votes
                      </p>
                      <p className="text-sm text-gray-600">
                        View all elections you've participated in
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <CheckCircle className="w-5 h-5 text-indigo-600" />
                    <svg
                      className="w-5 h-5 text-indigo-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M9 5l7 7-7 7"
                      />
                    </svg>
                  </div>
                </div>
              </Link>
            </div>
          </div>

          {/* Personal Information Section */}
          <div className="bg-white border border-gray-200 rounded-lg shadow-sm mb-6">
            <div className="p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-2">
                Personal Information
              </h2>
              <p className="text-sm text-gray-500 mb-6">
                Name fields are managed by administrators
              </p>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    First Name
                  </label>
                  <input
                    type="text"
                    value={user?.first_name || ""}
                    readOnly
                    className="w-full rounded-lg bg-gray-50 border border-gray-300 px-4 py-3 text-base text-gray-900 cursor-not-allowed"
                  />
                  <p className="mt-1 text-xs text-gray-500">
                    Managed by administrators
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Middle Initial
                  </label>
                  <input
                    type="text"
                    value={user?.middle_initial || ""}
                    readOnly
                    className="w-full rounded-lg bg-gray-50 border border-gray-300 px-4 py-3 text-base text-gray-900 cursor-not-allowed"
                  />
                  <p className="mt-1 text-xs text-gray-500">
                    Managed by administrators
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Last Name
                  </label>
                  <input
                    type="text"
                    value={user?.last_name || ""}
                    readOnly
                    className="w-full rounded-lg bg-gray-50 border border-gray-300 px-4 py-3 text-base text-gray-900 cursor-not-allowed"
                  />
                  <p className="mt-1 text-xs text-gray-500">
                    Managed by administrators
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Student Information Section */}
          <div className="bg-white border border-gray-200 rounded-lg shadow-sm mb-6">
            <div className="p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-2">
                Student Information
              </h2>
              <p className="text-sm text-gray-500 mb-6">
                Student identification and contact information
              </p>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Student ID
                  </label>
                  <input
                    {...profileForm.register("studentId")}
                    type="text"
                    readOnly
                    className="w-full rounded-lg bg-gray-50 border border-gray-300 px-4 py-3 text-base text-gray-900 cursor-not-allowed"
                  />
                  <p className="mt-1 text-xs text-gray-500">
                    Your unique student identification number
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    University Email (Alternative)
                  </label>
                  <input
                    {...profileForm.register("universityEmailAlt")}
                    type="email"
                    className="w-full rounded-lg bg-white border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors"
                  />
                  <p className="mt-1 text-xs text-gray-500">
                    Alternative university email if different
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Fisk Email
                  </label>
                  <input
                    {...profileForm.register("fiskEmail")}
                    type="email"
                    readOnly
                    className="w-full rounded-lg bg-gray-50 border border-gray-300 px-4 py-3 text-base text-gray-900 cursor-not-allowed"
                  />
                  <p className="mt-1 text-xs text-gray-500">
                    Your official Fisk University email address
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Personal Email
                  </label>
                  <input
                    {...profileForm.register("personalEmail")}
                    type="email"
                    className="w-full rounded-lg bg-white border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors"
                  />
                  <p className="mt-1 text-xs text-gray-500">
                    Optional personal email address (you can edit this)
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Phone Number & Address Section */}
          <div className="bg-white border border-gray-200 rounded-lg shadow-sm mb-6">
            <div className="p-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Phone Number
                  </label>
                  <input
                    {...profileForm.register("phoneNumber")}
                    type="tel"
                    className="w-full rounded-lg bg-white border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors"
                    placeholder=""
                  />
                  <p className="mt-1 text-xs text-gray-500">
                    Optional phone number (you can edit this)
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Address
                  </label>
                  <textarea
                    {...profileForm.register("address")}
                    rows={3}
                    className="w-full rounded-lg bg-white border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors resize-y"
                    placeholder=""
                  />
                  <p className="mt-1 text-xs text-gray-500">
                    Optional address information (you can edit this)
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Academic Information Section */}
          <div className="bg-white border border-gray-200 rounded-lg shadow-sm mb-6">
            <div className="p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-2">
                Academic Information
              </h2>
              <p className="text-sm text-gray-500 mb-6">Academic information</p>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Department / Program
                  </label>
                  <div className="relative">
                    <select
                      {...profileForm.register("department")}
                      className="w-full rounded-lg bg-white border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors appearance-none bg-[url('data:image/svg+xml;charset=UTF-8,%3csvg xmlns=%27http://www.w3.org/2000/svg%27 viewBox=%270 0 24 24%27 fill=%27none%27 stroke=%27%23374151%27 stroke-width=%272%27 stroke-linecap=%27round%27 stroke-linejoin=%27round%27%3e%3cpolyline points=%276 9 12 15 18 9%27%3e%3c/polyline%3e%3c/svg%3e')] bg-[length:20px_20px] bg-[right_12px_center] bg-no-repeat pr-10"
                    >
                      <option value="">Select an option</option>
                      <option value="computer-science">Computer Science</option>
                      <option value="business">Business</option>
                      <option value="engineering">Engineering</option>
                    </select>
                    <button
                      type="button"
                      className="absolute right-10 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                      onClick={() => {
                        // TODO: Open modal to create new department
                      }}
                    >
                      <svg
                        className="w-5 h-5"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M12 4v16m8-8H4"
                        />
                      </svg>
                    </button>
                  </div>
                  <p className="mt-1 text-xs text-gray-500">
                    Select your department or create a new one (you can edit this)
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Major
                  </label>
                  <div className="relative">
                    <select
                      {...profileForm.register("major")}
                      className="w-full rounded-lg bg-white border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors appearance-none bg-[url('data:image/svg+xml;charset=UTF-8,%3csvg xmlns=%27http://www.w3.org/2000/svg%27 viewBox=%270 0 24 24%27 fill=%27none%27 stroke=%27%23374151%27 stroke-width=%272%27 stroke-linecap=%27round%27 stroke-linejoin=%27round%27%3e%3cpolyline points=%276 9 12 15 18 9%27%3e%3c/polyline%3e%3c/svg%3e')] bg-[length:20px_20px] bg-[right_12px_center] bg-no-repeat pr-10"
                    >
                      <option value="">Select an option</option>
                      <option value="software-engineering">
                        Software Engineering
                      </option>
                      <option value="data-science">Data Science</option>
                      <option value="cybersecurity">Cybersecurity</option>
                    </select>
                    <button
                      type="button"
                      className="absolute right-10 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                      onClick={() => {
                        // TODO: Open modal to create new major
                      }}
                    >
                      <svg
                        className="w-5 h-5"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M12 4v16m8-8H4"
                        />
                      </svg>
                    </button>
                  </div>
                  <p className="mt-1 text-xs text-gray-500">
                    Select your major or create a new one (you can edit this)
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Class Level
                  </label>
                  <select
                    {...profileForm.register("classLevel")}
                    className="w-full rounded-lg bg-white border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors appearance-none bg-[url('data:image/svg+xml;charset=UTF-8,%3csvg xmlns=%27http://www.w3.org/2000/svg%27 viewBox=%270 0 24 24%27 fill=%27none%27 stroke=%27%23374151%27 stroke-width=%272%27 stroke-linecap=%27round%27 stroke-linejoin=%27round%27%3e%3cpolyline points=%276 9 12 15 18 9%27%3e%3c/polyline%3e%3c/svg%3e')] bg-[length:20px_20px] bg-[right_12px_center] bg-no-repeat pr-10"
                  >
                    <option value="">Select an option</option>
                    <option value="freshman">Freshman</option>
                    <option value="sophomore">Sophomore</option>
                    <option value="junior">Junior</option>
                    <option value="senior">Senior</option>
                    <option value="graduate">Graduate</option>
                  </select>
                  <p className="mt-1 text-xs text-gray-500">
                    Select your current class level (you can edit this)
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Student Type
                  </label>
                  <select
                    {...profileForm.register("studentType")}
                    className="w-full rounded-lg bg-white border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors appearance-none bg-[url('data:image/svg+xml;charset=UTF-8,%3csvg xmlns=%27http://www.w3.org/2000/svg%27 viewBox=%270 0 24 24%27 fill=%27none%27 stroke=%27%23374151%27 stroke-width=%272%27 stroke-linecap=%27round%27 stroke-linejoin=%27round%27%3e%3cpolyline points=%276 9 12 15 18 9%27%3e%3c/polyline%3e%3c/svg%3e')] bg-[length:20px_20px] bg-[right_12px_center] bg-no-repeat pr-10"
                  >
                    <option value="">Select an option</option>
                    <option value="undergraduate">Undergraduate</option>
                    <option value="graduate">Graduate</option>
                    <option value="part-time">Part-time</option>
                    <option value="full-time">Full-time</option>
                  </select>
                  <p className="mt-1 text-xs text-gray-500">
                    Select your student type (you can edit this)
                  </p>
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Citizenship Status
                  </label>
                  <input
                    {...profileForm.register("citizenshipStatus")}
                    type="text"
                    className="w-full rounded-lg bg-white border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors"
                    placeholder=""
                  />
                  <p className="mt-1 text-xs text-gray-500">
                    Enter your citizenship status (you can edit this)
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Organizations / Clubs Section */}
          <div className="bg-white border border-gray-200 rounded-lg shadow-sm mb-6">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h2 className="text-xl font-bold text-gray-900">
                    Organizations / Clubs
                  </h2>
                  <p className="text-sm text-gray-500 mt-1">
                    Your organizational memberships
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => setShowOrganizations(!showOrganizations)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <svg
                    className={`w-5 h-5 transition-transform ${showOrganizations ? "rotate-180" : ""}`}
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M5 15l7-7 7 7"
                    />
                  </svg>
                </button>
              </div>

              {showOrganizations && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Organizations / Clubs
                  </label>
                  <select
                    {...profileForm.register("organizations")}
                    className="w-full rounded-lg bg-white border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors appearance-none bg-[url('data:image/svg+xml;charset=UTF-8,%3csvg xmlns=%27http://www.w3.org/2000/svg%27 viewBox=%270 0 24 24%27 fill=%27none%27 stroke=%27%23374151%27 stroke-width=%272%27 stroke-linecap=%27round%27 stroke-linejoin=%27round%27%3e%3cpolyline points=%276 9 12 15 18 9%27%3e%3c/polyline%3e%3c/svg%3e')] bg-[length:20px_20px] bg-[right_12px_center] bg-no-repeat pr-10"
                  >
                    <option value="">Select an option</option>
                    <option value="student-government">
                      Student Government
                    </option>
                    <option value="debate-club">Debate Club</option>
                    <option value="tech-society">Tech Society</option>
                  </select>
                  <p className="mt-1 text-xs text-gray-500">
                    Select organizations or clubs you are part of (you can edit
                    this)
                  </p>
                </div>
              )}
            </div>
          </div>

          {/* Save Button */}
          <div className="flex justify-end mb-6">
            <Button type="submit" disabled={isSaving} className="px-8">
              {isSaving ? "Saving..." : "Save Changes"}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
