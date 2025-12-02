import { z } from "zod";

// Login schema
export const loginSchema = z.object({
  email: z
    .string()
    .min(1, "Email address is required")
    .email("Please provide a valid email address")
    .endsWith("@my.fisk.edu", "Please use your Fisk University email address"),
  password: z.string().min(1, "Password is required"),
});

export type LoginFormData = z.infer<typeof loginSchema>;

// Registration schema
export const registerSchema = z
  .object({
    first_name: z
      .string()
      .min(1, "First name is required")
      .max(255, "First name may not be greater than 255 characters"),
    middle_initial: z
      .string()
      .max(255, "Middle initial may not be greater than 255 characters")
      .optional()
      .or(z.literal("")),
    last_name: z
      .string()
      .min(1, "Last name is required")
      .max(255, "Last name may not be greater than 255 characters"),
    student_id: z
      .string()
      .min(1, "Student ID is required")
      .regex(/^\d+$/, "Student ID must contain only numbers")
      .max(255, "Student ID may not be greater than 255 characters"),
    email: z
      .string()
      .min(1, "Email address is required")
      .email("Please provide a valid email address")
      .endsWith("@my.fisk.edu", "Please use your Fisk University email address ending with @my.fisk.edu")
      .max(255, "Email may not be greater than 255 characters"),
    password: z
      .string()
      .min(8, "Password must be at least 8 characters")
      .regex(/[A-Z]/, "Password must contain at least one uppercase letter")
      .regex(/[a-z]/, "Password must contain at least one lowercase letter")
      .regex(/[0-9]/, "Password must contain at least one number"),
    passwordConfirmation: z.string().min(1, "Password confirmation is required"),
    accept_terms: z.boolean().refine((val) => val === true, {
      message: "You must accept the Terms of Service and Voting Policy to register",
    }),
  })
  .refine((data) => data.password === data.passwordConfirmation, {
    message: "The password confirmation does not match",
    path: ["passwordConfirmation"],
  });

export type RegisterFormData = z.infer<typeof registerSchema>;

// Forgot password schema
export const forgotPasswordSchema = z.object({
  email: z
    .string()
    .min(1, "Email address is required")
    .email("Please provide a valid email address")
    .endsWith("@my.fisk.edu", "Please use your Fisk University email address"),
});

export type ForgotPasswordFormData = z.infer<typeof forgotPasswordSchema>;

// Reset password schema
export const resetPasswordSchema = z
  .object({
    password: z
      .string()
      .min(8, "Password must be at least 8 characters")
      .regex(/[A-Z]/, "Password must contain at least one uppercase letter")
      .regex(/[a-z]/, "Password must contain at least one lowercase letter")
      .regex(/[0-9]/, "Password must contain at least one number"),
    passwordConfirmation: z.string().min(1, "Password confirmation is required"),
  })
  .refine((data) => data.password === data.passwordConfirmation, {
    message: "The password confirmation does not match",
    path: ["passwordConfirmation"],
  });

export type ResetPasswordFormData = z.infer<typeof resetPasswordSchema>;

