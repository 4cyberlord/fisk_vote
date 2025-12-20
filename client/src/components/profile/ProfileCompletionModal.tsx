"use client";

import { useState, useEffect, useMemo } from "react";
import { useForm } from "react-hook-form";
import { api } from "@/lib/axios";
import { useQueryClient } from "@tanstack/react-query";
import { useCurrentUser } from "@/hooks/useAuth";
import toast from "react-hot-toast";
import { X, Loader2 } from "lucide-react";

interface ProfileCompletionFormData {
  department: string;
  major: string;
  classLevel: string;
  studentType: string;
  citizenshipStatus: string;
  personalEmail: string;
  phoneNumber: string;
  address: string;
}

interface Department {
  id: number;
  name: string;
}

interface Major {
  id: number;
  name: string;
}

export function ProfileCompletionModal() {
  const { data: userData, refetch } = useCurrentUser();
  const queryClient = useQueryClient();
  const [isOpen, setIsOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [majors, setMajors] = useState<Major[]>([]);
  const [isLoadingDepartments, setIsLoadingDepartments] = useState(false);
  const [isLoadingMajors, setIsLoadingMajors] = useState(false);

  const user = userData?.data;

  const profileForm = useForm<ProfileCompletionFormData>({
    defaultValues: {
      department: "",
      major: "",
      classLevel: "",
      studentType: "",
      citizenshipStatus: "",
      personalEmail: "",
      phoneNumber: "",
      address: "",
    },
  });

  // Check if profile is complete
  const isProfileComplete = useMemo(() => {
    if (!user) return false;
    const hasAcademicInfo =
      (user.department && user.department.length > 0) ||
      (user.major && user.major.length > 0);
    return (
      hasAcademicInfo &&
      user.class_level &&
      user.class_level.length > 0 &&
      user.student_type &&
      user.student_type.length > 0
    );
  }, [user]);

  // Load departments and majors
  useEffect(() => {
    const loadDepartments = async () => {
      setIsLoadingDepartments(true);
      try {
        const response = await api.get<{ success: boolean; data: Department[] }>(
          "/departments"
        );
        if (response.data.success) {
          setDepartments(response.data.data);
        }
      } catch (error) {
        console.error("Failed to load departments:", error);
      } finally {
        setIsLoadingDepartments(false);
      }
    };

    const loadMajors = async () => {
      setIsLoadingMajors(true);
      try {
        const response = await api.get<{ success: boolean; data: Major[] }>(
          "/majors"
        );
        if (response.data.success) {
          setMajors(response.data.data);
        }
      } catch (error) {
        console.error("Failed to load majors:", error);
      } finally {
        setIsLoadingMajors(false);
      }
    };

    loadDepartments();
    loadMajors();
  }, []);

  // Pre-fill form when user data loads
  useEffect(() => {
    if (user) {
      profileForm.reset({
        department: user.department || "",
        major: user.major || "",
        classLevel: user.class_level || "",
        studentType: user.student_type || "",
        citizenshipStatus: user.citizenship_status || "",
        personalEmail: user.personal_email || "",
        phoneNumber: user.phone_number || "",
        address: user.address || "",
      });
    }
  }, [user, profileForm]);

  // Show modal if profile is incomplete
  useEffect(() => {
    if (user && !isProfileComplete) {
      setIsOpen(true);
    } else {
      setIsOpen(false);
    }
  }, [user, isProfileComplete]);

  // Calculate progress
  const progress = useMemo(() => {
    const requiredFields = [
      profileForm.watch("department") || profileForm.watch("major"),
      profileForm.watch("classLevel"),
      profileForm.watch("studentType"),
    ];
    const filled = requiredFields.filter(Boolean).length;
    return (filled / requiredFields.length) * 100;
  }, [
    profileForm.watch("department"),
    profileForm.watch("major"),
    profileForm.watch("classLevel"),
    profileForm.watch("studentType"),
  ]);

  // Check if form is valid
  const isFormValid = useMemo(() => {
    const department = profileForm.watch("department");
    const major = profileForm.watch("major");
    const classLevel = profileForm.watch("classLevel");
    const studentType = profileForm.watch("studentType");

    return (
      (department && department.length > 0) ||
      (major && major.length > 0)
    ) &&
      classLevel &&
      classLevel.length > 0 &&
      studentType &&
      studentType.length > 0;
  }, [
    profileForm.watch("department"),
    profileForm.watch("major"),
    profileForm.watch("classLevel"),
    profileForm.watch("studentType"),
  ]);

  const onSubmit = async (data: ProfileCompletionFormData) => {
    setIsSubmitting(true);
    try {
      const updateData: any = {};

      if (data.department) updateData.department = data.department;
      if (data.major) updateData.major = data.major;
      if (data.classLevel) updateData.class_level = data.classLevel;
      if (data.studentType) updateData.student_type = data.studentType;
      if (data.citizenshipStatus) updateData.citizenship_status = data.citizenshipStatus;
      if (data.personalEmail) updateData.personal_email = data.personalEmail;
      if (data.phoneNumber) updateData.phone_number = data.phoneNumber.replace(/-/g, "");
      if (data.address) updateData.address = data.address;

      await api.put("/students/me", updateData);

      // Refresh user data
      await queryClient.invalidateQueries({ queryKey: ["user", "current"] });
      await refetch();

      toast.success("Profile completed successfully!");
      setIsOpen(false);
    } catch (error: any) {
      const message =
        error?.response?.data?.message || "Failed to update profile";
      toast.error(message);
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div 
      className="fixed inset-0 z-[9999] flex items-center justify-center bg-black/60 backdrop-blur-sm"
      onClick={(e) => {
        // Prevent closing by clicking outside
        e.stopPropagation();
      }}
    >
      <div 
        className="bg-white rounded-xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto m-4"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between z-10">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">
              Complete Your Profile
            </h2>
            <p className="text-sm text-gray-600 mt-1">
              Please fill in the required information to continue using the application
            </p>
            <p className="text-xs text-amber-600 mt-2 font-medium">
              ⚠️ This form must be completed before you can access the application
            </p>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="px-6 py-4 bg-gray-50 border-b border-gray-200">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-medium text-gray-700">
              Profile Completion
            </span>
            <span className="text-sm font-bold text-indigo-600">
              {Math.round(progress)}%
            </span>
          </div>
          <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
            <div
              className="h-full bg-indigo-600 transition-all duration-300 rounded-full"
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>

        {/* Form */}
        <form onSubmit={profileForm.handleSubmit(onSubmit)}>
          <div className="p-6 space-y-6">
            {/* Required Fields Section */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">
                Required Information
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* Department */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Department <span className="text-red-500">*</span>
                  </label>
                  {isLoadingDepartments ? (
                    <div className="flex items-center justify-center h-12 border border-gray-300 rounded-lg">
                      <Loader2 className="w-5 h-5 animate-spin text-indigo-600" />
                    </div>
                  ) : departments.length > 0 ? (
                    <select
                      {...profileForm.register("department", {
                        required: !profileForm.watch("major"),
                      })}
                      className="w-full rounded-lg border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                    >
                      <option value="">Select Department</option>
                      {departments.map((dept) => (
                        <option key={dept.id} value={dept.name}>
                          {dept.name}
                        </option>
                      ))}
                    </select>
                  ) : (
                    <input
                      {...profileForm.register("department", {
                        required: !profileForm.watch("major"),
                      })}
                      type="text"
                      placeholder="Enter department"
                      className="w-full rounded-lg border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                    />
                  )}
                  {profileForm.formState.errors.department && (
                    <p className="mt-1 text-xs text-red-600">
                      {profileForm.formState.errors.department.message}
                    </p>
                  )}
                </div>

                {/* Major */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Major <span className="text-red-500">*</span>
                  </label>
                  {isLoadingMajors ? (
                    <div className="flex items-center justify-center h-12 border border-gray-300 rounded-lg">
                      <Loader2 className="w-5 h-5 animate-spin text-indigo-600" />
                    </div>
                  ) : majors.length > 0 ? (
                    <select
                      {...profileForm.register("major")}
                      className="w-full rounded-lg border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                    >
                      <option value="">Select Major</option>
                      {majors.map((major) => (
                        <option key={major.id} value={major.name}>
                          {major.name}
                        </option>
                      ))}
                    </select>
                  ) : (
                    <input
                      {...profileForm.register("major")}
                      type="text"
                      placeholder="Enter major"
                      className="w-full rounded-lg border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                    />
                  )}
                  {profileForm.formState.errors.major && (
                    <p className="mt-1 text-xs text-red-600">
                      {profileForm.formState.errors.major.message}
                    </p>
                  )}
                </div>

                {/* Class Level */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Class Level <span className="text-red-500">*</span>
                  </label>
                  <select
                    {...profileForm.register("classLevel", { required: true })}
                    className="w-full rounded-lg border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                  >
                    <option value="">Select Class Level</option>
                    <option value="Freshman">Freshman</option>
                    <option value="Sophomore">Sophomore</option>
                    <option value="Junior">Junior</option>
                    <option value="Senior">Senior</option>
                  </select>
                  {profileForm.formState.errors.classLevel && (
                    <p className="mt-1 text-xs text-red-600">
                      {profileForm.formState.errors.classLevel.message}
                    </p>
                  )}
                </div>

                {/* Student Type */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Student Type <span className="text-red-500">*</span>
                  </label>
                  <select
                    {...profileForm.register("studentType", { required: true })}
                    className="w-full rounded-lg border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                  >
                    <option value="">Select Student Type</option>
                    <option value="Undergraduate">Undergraduate</option>
                    <option value="Graduate">Graduate</option>
                    <option value="Transfer">Transfer</option>
                    <option value="International">International</option>
                  </select>
                  {profileForm.formState.errors.studentType && (
                    <p className="mt-1 text-xs text-red-600">
                      {profileForm.formState.errors.studentType.message}
                    </p>
                  )}
                </div>
              </div>
            </div>

            {/* Optional Fields Section */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">
                Optional Information
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* Citizenship Status */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Citizenship Status
                  </label>
                  <input
                    {...profileForm.register("citizenshipStatus")}
                    type="text"
                    placeholder="Enter citizenship status"
                    className="w-full rounded-lg border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                  />
                </div>

                {/* Personal Email */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Personal Email
                  </label>
                  <input
                    {...profileForm.register("personalEmail", {
                      pattern: {
                        value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
                        message: "Invalid email address",
                      },
                    })}
                    type="email"
                    placeholder="your.email@example.com"
                    className="w-full rounded-lg border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                  />
                  {profileForm.formState.errors.personalEmail && (
                    <p className="mt-1 text-xs text-red-600">
                      {profileForm.formState.errors.personalEmail.message}
                    </p>
                  )}
                </div>

                {/* Phone Number */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Phone Number
                  </label>
                  <input
                    {...profileForm.register("phoneNumber")}
                    type="tel"
                    placeholder="123-456-7890"
                    className="w-full rounded-lg border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                  />
                </div>

                {/* Address */}
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Address
                  </label>
                  <textarea
                    {...profileForm.register("address")}
                    rows={3}
                    placeholder="Enter your address"
                    className="w-full rounded-lg border border-gray-300 px-4 py-3 text-base text-gray-900 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none resize-y"
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Footer */}
          <div className="sticky bottom-0 bg-gray-50 border-t border-gray-200 px-6 py-4 flex items-center justify-end gap-3">
            <button
              type="submit"
              disabled={!isFormValid || isSubmitting}
              className="px-6 py-3 bg-indigo-600 text-white font-semibold rounded-lg hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center gap-2"
            >
              {isSubmitting ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin" />
                  Saving...
                </>
              ) : (
                "Complete Profile"
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

