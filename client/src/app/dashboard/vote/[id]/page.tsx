"use client";

import { useParams, useRouter } from "next/navigation";
import { useState, useEffect, useMemo } from "react";
import dynamic from "next/dynamic";
import { useBallot, useCastVote } from "@/hooks/useElections";
import { Button } from "@/components";
import toast from "react-hot-toast";
import dayjs from "dayjs";
import Avatar, { genConfig } from "react-nice-avatar";

// Helper component to render candidate avatar
function CandidateAvatar({ 
  candidate, 
  size = 40 
}: { 
  candidate: { 
    id: number;
    photo_url?: string | null;
    user?: { 
      profile_photo?: string | null;
      email?: string | null;
      university_email?: string | null;
      student_id?: string | null;
      name?: string | null;
      first_name?: string | null;
      last_name?: string | null;
    } | null;
  }; 
  size?: number;
}) {
  const [imageError, setImageError] = useState(false);
  const [imageSrc, setImageSrc] = useState<string | null>(null);
  
  const BACKEND_URL = process.env.NEXT_PUBLIC_BACKEND_URL || "http://localhost:8000";

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
  const getImageUrl = (url: string | null | undefined): string | null => {
    if (!url) return null;
    // If it's already an absolute URL (starts with http:// or https://), return as is
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    // If it starts with /, prepend backend URL
    if (url.startsWith('/')) {
      return `${BACKEND_URL}${url}`;
    }
    // Otherwise, assume it's a relative path and prepend backend URL with /
    return `${BACKEND_URL}/${url}`;
  };

  // Determine which image to use (priority: candidate.photo_url > candidate.user.profile_photo)
  useEffect(() => {
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

export default function CastVotePage() {
  const params = useParams();
  const router = useRouter();
  const electionId = params?.id ? parseInt(params.id as string) : null;
  const { data: ballotData, isLoading, error } = useBallot(electionId);
  const castVoteMutation = useCastVote();

  const [votes, setVotes] = useState<Record<string, number | number[] | Array<{ candidate_id: number }> | boolean>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showConfetti, setShowConfetti] = useState(false);

  const Confetti = dynamic(() => import("react-confetti"), { ssr: false });

  // Initialize votes from existing vote if user has already voted
  useEffect(() => {
    if (ballotData?.has_voted && ballotData.existing_vote && Object.keys(votes).length === 0) {
      // Votes are already cast, this is handled in the read-only view
    }
  }, [ballotData, votes]);

  const handleVoteChange = (
    positionId: number,
    value: number | number[] | Array<{ candidate_id: number }> | null
  ) => {
    const fieldKey = `position_${positionId}`;
    setVotes((prev) => ({
      ...prev,
      [fieldKey]: value,
    }));
  };

  const handleAbstainChange = (positionId: number, abstain: boolean) => {
    const fieldKey = `position_${positionId}`;
    const abstainKey = `${fieldKey}_abstain`;
    
    setVotes((prev) => {
      const newVotes = { ...prev };
      if (abstain) {
        delete newVotes[fieldKey];
        newVotes[abstainKey] = true;
      } else {
        delete newVotes[abstainKey];
      }
      return newVotes;
    });
  };

  const handleSubmit = async () => {
    if (!electionId || !ballotData) return;

    // Validate votes
    let hasError = false;
    for (const position of ballotData.positions) {
      const fieldKey = `position_${position.id}`;
      const abstainKey = `${fieldKey}_abstain`;

      if (!votes[abstainKey] && !votes[fieldKey]) {
        if (!position.allow_abstain) {
          toast.error(`Please select a candidate for ${position.name} or abstain.`);
          hasError = true;
        }
      }

      // Validate max_selection for multiple choice
      if (position.type === "multiple" && votes[fieldKey]) {
        const selected = Array.isArray(votes[fieldKey]) ? votes[fieldKey] : [votes[fieldKey]];
        if (position.max_selection && selected.length > position.max_selection) {
          toast.error(
            `You can only select up to ${position.max_selection} candidate(s) for ${position.name}.`
          );
          hasError = true;
        }
      }
    }

    if (hasError) return;

    setIsSubmitting(true);
    try {
      // Format votes for backend (convert ranked votes to proper format)
      const formattedVotes: Record<string, unknown> = {};
      for (const [key, voteValue] of Object.entries(votes)) {
        if (key.endsWith("_abstain")) {
          formattedVotes[key] = voteValue;
        } else if (Array.isArray(voteValue) && voteValue.length > 0) {
          // Check if it's ranked choice (array of objects with candidate_id)
          if (typeof voteValue[0] === "object" && voteValue[0] !== null && "candidate_id" in voteValue[0]) {
            formattedVotes[key] = voteValue;
          } else {
            // Multiple choice (array of numbers)
            formattedVotes[key] = voteValue;
          }
        } else {
          formattedVotes[key] = voteValue;
        }
      }

      await castVoteMutation.mutateAsync({
        electionId,
        voteData: { votes: formattedVotes },
      });

      toast.success("Your vote has been successfully submitted. Thank you for participating!");
      setShowConfetti(true);

      // Give the user a brief celebration before navigating away
      setTimeout(() => {
        setShowConfetti(false);
        router.push("/dashboard/vote");
      }, 2000);
    } catch (error: unknown) {
      const errorMessage =
        error && typeof error === "object" && "message" in error
          ? String(error.message)
          : "Failed to submit vote. Please try again.";
      toast.error(errorMessage);
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-full bg-white">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="h-full overflow-y-auto bg-gray-50">
        <div className="p-8 max-w-7xl mx-auto">
          <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
            <h1 className="text-2xl font-bold text-red-900 mb-2">Error</h1>
            <p className="text-red-700 mb-4">
              {error instanceof Error ? error.message : "Failed to load ballot data."}
            </p>
            <Button onClick={() => router.push("/dashboard/vote")}>Back to Voting</Button>
          </div>
        </div>
      </div>
    );
  }

  if (!ballotData) {
    return (
      <div className="h-full overflow-y-auto bg-gray-50">
        <div className="p-8 max-w-7xl mx-auto">
          <div className="bg-gray-50 border border-gray-200 rounded-lg p-6 text-center">
            <p className="text-gray-600">No ballot data available.</p>
            <Button onClick={() => router.push("/dashboard/vote")} className="mt-4">
              Back to Voting
            </Button>
          </div>
        </div>
      </div>
    );
  }

  // If user has already voted, show read-only view
  if (ballotData.has_voted) {
    return (
      <div className="h-full overflow-y-auto bg-gray-50">
        <div className="p-8 max-w-7xl mx-auto">
          <div className="mb-10">
            <button
              onClick={() => router.push("/dashboard/vote")}
              className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:border-gray-400 transition-all duration-200 shadow-sm hover:shadow-md"
            >
              <svg
                className="w-4 h-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M15 19l-7-7 7-7"
                />
              </svg>
              Back to Cast Page
            </button>
          </div>

          <div className="bg-indigo-50 border border-indigo-200 rounded-lg p-4 mb-8">
            <div className="flex items-center gap-2">
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
                  d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              <p className="text-indigo-800 font-medium">
                You have already voted in this election.
              </p>
            </div>
          </div>

          <div className="bg-white border border-gray-200 rounded-lg shadow-sm p-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-2">{ballotData.election.title}</h1>
            <p className="text-gray-600 mb-6">{ballotData.election.description || "--"}</p>

            <div className="space-y-6">
              {ballotData.positions.map((position) => (
                <div key={position.id} className="border border-gray-200 rounded-lg p-6">
                  <h3 className="text-xl font-semibold text-gray-900 mb-2">{position.name}</h3>
                  <p className="text-gray-600 text-sm mb-4">{position.description || "--"}</p>
                  <div className="space-y-3">
                    {position.candidates.map((candidate) => (
                      <div
                        key={candidate.id}
                        className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg"
                      >
                        <div className="h-10 w-10 rounded-full bg-indigo-600 flex items-center justify-center text-white font-semibold">
                          {candidate.user?.first_name?.[0] || "--"}
                          {candidate.user?.last_name?.[0] || ""}
                        </div>
                        <div className="flex-1">
                          <p className="font-medium text-gray-900">
                            {candidate.user?.name ||
                              (candidate.user?.first_name && candidate.user?.last_name
                                ? `${candidate.user.first_name} ${candidate.user.last_name}`
                                : "--")}
                          </p>
                          {candidate.tagline && (
                            <p className="text-sm text-gray-600">{candidate.tagline}</p>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Check if election is open
  if (ballotData.election.current_status !== "Open") {
    return (
      <div className="h-full overflow-y-auto bg-gray-50">
        <div className="p-8 max-w-7xl mx-auto">
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6 text-center">
            <h1 className="text-2xl font-bold text-yellow-900 mb-2">Election Not Open</h1>
            <p className="text-yellow-700 mb-4">
              This election is not currently open for voting. Status:{" "}
              {ballotData.election.current_status}
            </p>
            <Button onClick={() => router.push("/dashboard/vote")}>Back to Voting</Button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full overflow-y-auto bg-gray-50 relative">
      {showConfetti && <Confetti recycle={false} numberOfPieces={250} />}
      <div className="p-8 max-w-7xl mx-auto">
        <div className="mb-6">
          <button
            onClick={() => router.push("/dashboard/vote")}
            className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:border-gray-400 transition-all duration-200 shadow-sm hover:shadow-md"
          >
            <svg
              className="w-4 h-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M15 19l-7-7 7-7"
              />
            </svg>
            Back to Cast Page
          </button>
        </div>

        <div className="bg-white border border-gray-200 rounded-lg shadow-sm p-8 mb-6">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">{ballotData.election.title}</h1>
          <p className="text-gray-600 mb-4">{ballotData.election.description || "--"}</p>
          <div className="flex items-center gap-4 text-sm text-gray-500">
            <div className="flex items-center gap-1">
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                />
              </svg>
              <span>
                {dayjs(ballotData.election.start_time).format("MMM D, YYYY [at] h:mm A")} -{" "}
                {dayjs(ballotData.election.end_time).format("MMM D, YYYY [at] h:mm A")}
              </span>
            </div>
          </div>
        </div>

        <form
          onSubmit={(e) => {
            e.preventDefault();
            handleSubmit();
          }}
        >
          <div className="space-y-6 mb-8">
            {ballotData.positions.map((position) => (
              <BallotPositionSection
                key={position.id}
                position={position}
                value={votes[`position_${position.id}`]}
                abstain={!!votes[`position_${position.id}_abstain`]}
                onVoteChange={(value) => handleVoteChange(position.id, value)}
                onAbstainChange={(abstain) => handleAbstainChange(position.id, abstain)}
              />
            ))}
          </div>

          <div className="bg-white border border-gray-200 rounded-lg p-6 flex items-center justify-between">
            <p className="text-sm text-gray-600">
              Please review your selections carefully. Once submitted, your vote cannot be changed.
            </p>
            <Button
              type="submit"
              disabled={isSubmitting || castVoteMutation.isPending}
              className="px-8 py-3"
            >
              {isSubmitting || castVoteMutation.isPending ? "Submitting..." : "Submit Vote"}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}

interface BallotPositionSectionProps {
  position: {
    id: number;
    name: string;
    description: string | null;
    type: "single" | "multiple" | "ranked";
    max_selection: number | null;
    ranking_levels: number | null;
    allow_abstain: boolean;
    candidates: Array<{
      id: number;
      user: {
        name: string;
        first_name: string;
        last_name: string;
        profile_photo: string | null;
      } | null;
      photo_url: string | null;
      tagline: string | null;
      bio: string | null;
    }>;
  };
  value: number | number[] | boolean | undefined;
  abstain: boolean;
  onVoteChange: (value: number | number[] | null) => void;
  onAbstainChange: (abstain: boolean) => void;
}

function BallotPositionSection({
  position,
  value,
  abstain,
  onVoteChange,
  onAbstainChange,
}: BallotPositionSectionProps) {
  return (
    <div className="bg-white border border-gray-200 rounded-lg shadow-sm p-6">
      <div className="mb-4">
        <h3 className="text-xl font-semibold text-gray-900 mb-2">{position.name}</h3>
        {position.description && (
          <p className="text-gray-600 text-sm mb-2">{position.description}</p>
        )}
        {position.type === "multiple" && position.max_selection && (
          <p className="text-sm text-gray-500">
            Select up to {position.max_selection} candidate(s).
          </p>
        )}
        {position.type === "ranked" && position.ranking_levels && (
          <p className="text-sm text-gray-500">
            Rank up to {position.ranking_levels} candidate(s) in order of preference.
          </p>
        )}
      </div>

      {position.type === "single" && (
        <div className="space-y-3">
          {position.candidates.map((candidate) => (
            <label
              key={candidate.id}
              className={`flex items-start gap-3 p-4 border-2 rounded-lg cursor-pointer transition-all ${
                value === candidate.id
                  ? "border-indigo-500 bg-indigo-50"
                  : "border-gray-200 hover:border-gray-300"
              } ${abstain ? "opacity-50 pointer-events-none" : ""}`}
            >
              <input
                type="radio"
                name={`position_${position.id}`}
                value={candidate.id}
                checked={value === candidate.id}
                onChange={() => onVoteChange(candidate.id)}
                className="mt-1"
                disabled={abstain}
              />
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <div className="flex-shrink-0">
                    <CandidateAvatar candidate={candidate} size={40} />
                  </div>
                  <div>
                    <p className="font-medium text-gray-900">
                      {candidate.user?.name ||
                        (candidate.user?.first_name && candidate.user?.last_name
                          ? `${candidate.user.first_name} ${candidate.user.last_name}`
                          : "--")}
                    </p>
                    {candidate.tagline && (
                      <p className="text-sm text-gray-600">{candidate.tagline}</p>
                    )}
                  </div>
                </div>
                {candidate.bio && (
                  <p className="text-sm text-gray-600 line-clamp-2">{candidate.bio}</p>
                )}
              </div>
            </label>
          ))}
        </div>
      )}

      {position.type === "multiple" && (
        <div className="space-y-3">
          {position.candidates.map((candidate) => {
            const selectedValues = Array.isArray(value) ? value : value ? [value] : [];
            const isSelected = selectedValues.includes(candidate.id);

            return (
              <label
                key={candidate.id}
                className={`flex items-start gap-3 p-4 border-2 rounded-lg cursor-pointer transition-all ${
                  isSelected
                    ? "border-indigo-500 bg-indigo-50"
                    : "border-gray-200 hover:border-gray-300"
                } ${abstain ? "opacity-50 pointer-events-none" : ""}`}
              >
                <input
                  type="checkbox"
                  checked={isSelected}
                  onChange={(e) => {
                    const currentValues = Array.isArray(value) ? value : value ? [value] : [];
                    if (e.target.checked) {
                      if (
                        !position.max_selection ||
                        currentValues.length < position.max_selection
                      ) {
                        onVoteChange([...currentValues, candidate.id]);
                      }
                    } else {
                      onVoteChange(currentValues.filter((id) => id !== candidate.id));
                    }
                  }}
                  className="mt-1"
                  disabled={abstain}
                />
                <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <div className="flex-shrink-0">
                    <CandidateAvatar candidate={candidate} size={40} />
                  </div>
                  <div>
                      <p className="font-medium text-gray-900">
                        {candidate.user?.name ||
                          (candidate.user?.first_name && candidate.user?.last_name
                            ? `${candidate.user.first_name} ${candidate.user.last_name}`
                            : "--")}
                      </p>
                      {candidate.tagline && (
                        <p className="text-sm text-gray-600">{candidate.tagline}</p>
                      )}
                    </div>
                  </div>
                  {candidate.bio && (
                    <p className="text-sm text-gray-600 line-clamp-2">{candidate.bio}</p>
                  )}
                </div>
              </label>
            );
          })}
        </div>
      )}

      {position.type === "ranked" && (
        <RankedChoiceVoting
          position={position}
          value={value}
          abstain={abstain}
          onVoteChange={onVoteChange}
          onAbstainChange={onAbstainChange}
        />
      )}

      {position.allow_abstain && (
        <div className="mt-4 pt-4 border-t border-gray-200">
          <label className="flex items-center gap-3 cursor-pointer">
            <input
              type="checkbox"
              checked={abstain}
              onChange={(e) => onAbstainChange(e.target.checked)}
              className="rounded"
            />
            <span className="text-sm text-gray-700">
              Abstain from voting for this position
            </span>
          </label>
        </div>
      )}
    </div>
  );
}

function RankedChoiceVoting({
  position,
  value,
  abstain,
  onVoteChange,
  onAbstainChange,
}: {
  position: BallotPositionSectionProps["position"];
  value: number | number[] | boolean | undefined;
  abstain: boolean;
  onVoteChange: (value: number | number[] | null) => void;
  onAbstainChange: (abstain: boolean) => void;
}) {
  // Parse ranked value
  const rankings = Array.isArray(value)
    ? value.map((item, index) => ({
        candidate_id: typeof item === "object" && "candidate_id" in item ? item.candidate_id : item,
        rank: index + 1,
      }))
    : [];

  const handleRankChange = (candidateId: number, newRank: number | null) => {
    let newRankings = [...rankings];

    // Remove candidate from current position if it exists
    newRankings = newRankings.filter((r) => r.candidate_id !== candidateId);

    if (newRank !== null) {
      // Adjust other rankings
      newRankings = newRankings.map((r) => {
        if (r.rank >= newRank) {
          return { ...r, rank: r.rank + 1 };
        }
        return r;
      });

      // Add candidate at new rank
      newRankings.push({ candidate_id: candidateId, rank: newRank });
      newRankings.sort((a, b) => a.rank - b.rank);
    }

    // Convert to format expected by backend
    const formattedRankings = newRankings.map((r) => ({ candidate_id: r.candidate_id }));
    onVoteChange(formattedRankings.length > 0 ? formattedRankings : null);
  };

  const getRankForCandidate = (candidateId: number) => {
    const ranking = rankings.find((r) => r.candidate_id === candidateId);
    return ranking ? ranking.rank : null;
  };

  const maxRank = position.ranking_levels || position.candidates.length;

  return (
    <div className="space-y-3">
      {position.candidates.map((candidate) => {
        const currentRank = getRankForCandidate(candidate.id);
        const isRanked = currentRank !== null;

        return (
          <div
            key={candidate.id}
            className={`flex items-center gap-3 p-4 border-2 rounded-lg transition-all ${
              isRanked
                ? "border-indigo-500 bg-indigo-50"
                : "border-gray-200 hover:border-gray-300"
            } ${abstain ? "opacity-50 pointer-events-none" : ""}`}
          >
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-2">
                <div className="flex-shrink-0">
                  <CandidateAvatar candidate={candidate} size={40} />
                </div>
                <div className="flex-1">
                  <p className="font-medium text-gray-900">
                    {candidate.user?.name ||
                      (candidate.user?.first_name && candidate.user?.last_name
                        ? `${candidate.user.first_name} ${candidate.user.last_name}`
                        : "--")}
                  </p>
                  {candidate.tagline && (
                    <p className="text-sm text-gray-600">{candidate.tagline}</p>
                  )}
                </div>
              </div>
              {candidate.bio && (
                <p className="text-sm text-gray-600 line-clamp-2">{candidate.bio}</p>
              )}
            </div>
            <div className="flex items-center gap-2">
              {isRanked && (
                <span className="px-3 py-1 rounded-full text-sm font-medium bg-indigo-600 text-white">
                  Rank {currentRank}
                </span>
              )}
              <select
                value={currentRank || ""}
                onChange={(e) =>
                  handleRankChange(
                    candidate.id,
                    e.target.value ? parseInt(e.target.value) : null
                  )
                }
                className="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                disabled={abstain}
              >
                <option value="">Select rank</option>
                {Array.from({ length: maxRank }, (_, i) => i + 1).map((rank) => {
                  const alreadyUsed = rankings.some(
                    (r) => r.rank === rank && r.candidate_id !== candidate.id
                  );
                  return (
                    <option key={rank} value={rank} disabled={alreadyUsed}>
                      {rank}
                      {alreadyUsed ? " (taken)" : ""}
                    </option>
                  );
                })}
              </select>
            </div>
          </div>
        );
      })}
    </div>
  );
}

