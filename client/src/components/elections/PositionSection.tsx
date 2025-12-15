"use client";

import { useState, useMemo, useEffect } from "react";
import { ElectionPosition, ElectionCandidate } from "@/services/electionService";
import Avatar, { genConfig } from "react-nice-avatar";

interface PositionSectionProps {
  position: ElectionPosition;
}

// Helper function to get candidate avatar
function CandidateAvatar({ 
  candidate, 
  size = 48 
}: { 
  candidate: ElectionCandidate; 
  size?: number;
}) {
  const [imageError, setImageError] = useState(false);
  const [imageSrc, setImageSrc] = useState<string | null>(null);
  
  const avatarConfig = useMemo(() => {
    const seed =
      candidate.user?.email ||
      candidate.user?.university_email ||
      candidate.user?.student_id ||
      candidate.user?.name ||
      candidate.user?.first_name ||
      candidate.user?.last_name ||
      `candidate-${candidate.id}`;
    return genConfig(seed);
  }, [candidate]);

  // Helper to convert relative URLs to absolute URLs
  const backendBase = process.env.NEXT_PUBLIC_BACKEND_URL?.replace(/\/+$/, "");

  const rewriteLocalhost = (url: string): string => {
    if (!backendBase) return url;
    try {
      const parsed = new URL(url);
      if (parsed.hostname === "localhost" || parsed.hostname === "127.0.0.1") {
        return url.replace(`${parsed.protocol}//${parsed.host}`, backendBase);
      }
    } catch {
      // ignore parse errors
    }
    return url;
  };

  const getImageUrl = (url: string | null | undefined): string | null => {
    if (!url) return null;
    // Absolute URL: rewrite localhost to backendBase if provided
    if (url.startsWith("http://") || url.startsWith("https://")) {
      return rewriteLocalhost(url);
    }
    // Protocol-relative
    if (url.startsWith("//")) {
      return `${window?.location?.protocol ?? "https:"}${url}`;
    }
    // Path starting with / -> prefix backend base if provided, else use as-is
    if (url.startsWith("/")) {
      if (backendBase) return `${backendBase}${url}`;
      return url;
    }
    // Bare path -> prefix backend base if provided, else make it relative
    if (backendBase) return `${backendBase}/${url.replace(/^\/+/, "")}`;
    return `/${url.replace(/^\/+/, "")}`;
  };

  // Determine which image to use (priority: candidate upload > user profile photo)
  useEffect(() => {
    // Use the candidate-specific photo uploaded in admin as the official election image.
    const photoUrl = candidate.photo_url ? getImageUrl(candidate.photo_url) : null;
    const profilePhoto = candidate.user?.profile_photo ? getImageUrl(candidate.user.profile_photo) : null;

    setImageSrc(photoUrl || profilePhoto || null);
    setImageError(false);
  }, [candidate.photo_url, candidate.user?.profile_photo]);

  const imageStyle = {
    width: `${size}px`,
    height: `${size}px`,
    borderRadius: '50%',
    objectFit: 'cover' as const,
  };

  // If we have an image source and no error, show the image
  if (imageSrc && !imageError) {
    return (
      <img
        src={imageSrc}
        alt={candidate.user?.name || "Candidate"}
        style={imageStyle}
        loading="lazy"
        onError={() => setImageError(true)}
      />
    );
  }

  // Fallback to react-nice-avatar
  return (
    <Avatar
      style={{ width: `${size}px`, height: `${size}px` }}
      {...avatarConfig}
    />
  );
}

export function PositionSection({ position }: PositionSectionProps) {
  const [selectedCandidate, setSelectedCandidate] =
    useState<ElectionCandidate | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <>
      <div className="bg-white border border-gray-200 rounded-lg shadow-sm overflow-hidden">
        {/* Position Header */}
        <div className="p-6 border-b border-gray-200 bg-gray-50">
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                {position.name || "Position"}
              </h3>
              {position.description ? (
                <p className="text-gray-600 text-sm">
                  {position.description}
                </p>
              ) : (
                <p className="text-gray-400 text-sm italic">
                  No description provided for this position.
                </p>
              )}
            </div>
            <div className="ml-4">
              <span className="px-3 py-1 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800 capitalize">
                {position.type || "--"}
              </span>
            </div>
          </div>
          <div className="mt-2">
            {position.type === "single" && (
              <p className="text-xs text-gray-500">
                Select one candidate for this position.
              </p>
            )}
            {position.type === "multiple" && (
              <p className="text-xs text-gray-500">
                {position.max_selection
                  ? `Select up to ${position.max_selection} candidate${position.max_selection > 1 ? "s" : ""} for this position.`
                  : "Select multiple candidates for this position."}
              </p>
            )}
            {position.type === "ranked" && (
              <p className="text-xs text-gray-500">
                {position.ranking_levels
                  ? `Rank up to ${position.ranking_levels} candidate${position.ranking_levels > 1 ? "s" : ""} in order of preference.`
                  : "Rank candidates in order of preference."}
              </p>
            )}
            {position.allow_abstain && (
              <p className="text-xs text-gray-500 mt-1">
                You may choose to abstain from voting for this position.
              </p>
            )}
          </div>
        </div>

        {/* Candidates List */}
        <div className="p-6">
          {position.candidates && position.candidates.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {position.candidates.map((candidate) => (
                <div
                  key={candidate.id}
                  onClick={() => {
                    setSelectedCandidate(candidate);
                    setIsModalOpen(true);
                  }}
                  className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-all cursor-pointer hover:border-indigo-300"
                >
                  {/* Candidate Photo/Avatar */}
                  <div className="flex items-center gap-3 mb-3">
                    <div className="flex-shrink-0">
                      <CandidateAvatar candidate={candidate} size={48} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h4 className="font-semibold text-gray-900 truncate">
                        {candidate.user?.name ||
                        (candidate.user?.first_name &&
                          candidate.user?.last_name
                          ? `${candidate.user.first_name} ${candidate.user.last_name}`
                          : "Candidate")}
                      </h4>
                      {candidate.tagline ? (
                        <p className="text-xs text-gray-500 truncate">
                          {candidate.tagline}
                        </p>
                      ) : (
                        <p className="text-xs text-gray-400 italic truncate">
                          No tagline provided
                        </p>
                      )}
                    </div>
                  </div>

                  {/* Candidate Bio */}
                  {candidate.bio ? (
                    <p className="text-sm text-gray-600 mb-3 line-clamp-3">
                      {candidate.bio}
                    </p>
                  ) : (
                    <p className="text-sm text-gray-400 italic mb-3">
                      No biography available.
                    </p>
                  )}

                  {/* Manifesto Preview */}
                  {candidate.manifesto ? (
                    <details className="mt-3">
                      <summary className="text-xs text-indigo-600 hover:text-indigo-700 cursor-pointer font-medium">
                        View Manifesto
                      </summary>
                      <div className="mt-2 p-3 bg-gray-50 rounded text-xs text-gray-700 whitespace-pre-wrap">
                        {candidate.manifesto}
                      </div>
                    </details>
                  ) : (
                    <p className="text-xs text-gray-400 italic mt-3">
                      No manifesto available.
                    </p>
                  )}

                  {!candidate.approved && (
                    <span className="inline-block mt-2 px-2 py-1 rounded text-xs font-medium bg-yellow-100 text-yellow-800">
                      Pending Approval
                    </span>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-8 text-gray-500">
              <p>No candidates for this position yet.</p>
            </div>
          )}
        </div>
      </div>

      {/* Candidate Detail Modal */}
      {isModalOpen && selectedCandidate && (
        <div
          className="fixed inset-0 z-[9999] flex items-center justify-center p-4 bg-black bg-opacity-30"
          style={{ 
            position: 'fixed', 
            top: 0, 
            left: 0, 
            right: 0, 
            bottom: 0,
            width: '100vw',
            height: '100vh',
            margin: 0,
            padding: '1rem'
          }}
          onClick={() => setIsModalOpen(false)}
        >
          <div
            className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
              <h2 className="text-2xl font-bold text-gray-900">
                Candidate Details
              </h2>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-gray-400 hover:text-gray-600 transition-colors p-2 hover:bg-gray-100 rounded-full"
                aria-label="Close modal"
              >
                <svg
                  className="w-6 h-6"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>

            {/* Modal Content */}
            <div className="p-6">
              {/* Candidate Header */}
              <div className="flex items-start gap-6 mb-6">
                <div className="flex-shrink-0">
                  <CandidateAvatar candidate={selectedCandidate} size={96} />
                </div>
                <div className="flex-1">
                  <h3 className="text-2xl font-bold text-gray-900 mb-2">
                    {selectedCandidate.user?.name ||
                      (selectedCandidate.user?.first_name &&
                        selectedCandidate.user?.last_name
                        ? `${selectedCandidate.user.first_name} ${selectedCandidate.user.last_name}`
                        : "--")}
                  </h3>
                  {selectedCandidate.tagline && (
                    <p className="text-lg text-gray-600 mb-2">
                      {selectedCandidate.tagline}
                    </p>
                  )}
                  {selectedCandidate.user?.email && (
                    <p className="text-sm text-gray-500">
                      {selectedCandidate.user.email}
                    </p>
                  )}
                  {!selectedCandidate.approved && (
                    <span className="inline-block mt-2 px-3 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                      Pending Approval
                    </span>
                  )}
                </div>
              </div>

              {/* Bio Section */}
              <div className="mb-6">
                <h4 className="text-lg font-semibold text-gray-900 mb-3">
                  Biography
                </h4>
                <div className="bg-gray-50 rounded-lg p-4">
                  <p className="text-gray-700 whitespace-pre-wrap">
                    {selectedCandidate.bio || "--"}
                  </p>
                </div>
              </div>

              {/* Manifesto Section */}
              {selectedCandidate.manifesto && (
                <div className="mb-6">
                  <h4 className="text-lg font-semibold text-gray-900 mb-3">
                    Manifesto
                  </h4>
                  <div className="bg-gray-50 rounded-lg p-4">
                    <p className="text-gray-700 whitespace-pre-wrap">
                      {selectedCandidate.manifesto}
                    </p>
                  </div>
                </div>
              )}
            </div>

            {/* Modal Footer */}
            <div className="sticky bottom-0 bg-gray-50 border-t border-gray-200 px-6 py-4 flex justify-end">
              <button
                onClick={() => setIsModalOpen(false)}
                className="px-6 py-2 bg-indigo-600 text-white rounded-lg font-medium hover:bg-indigo-700 transition-colors"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

