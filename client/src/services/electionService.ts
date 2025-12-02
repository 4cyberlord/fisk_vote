import { api } from "@/lib/axios";

export interface Election {
  id: number;
  title: string;
  description: string | null;
  type: "single" | "multiple" | "referendum" | "ranked" | "poll";
  max_selection: number | null;
  ranking_levels: number | null;
  allow_write_in: boolean;
  allow_abstain: boolean;
  start_time: string;
  end_time: string;
  status?: string; // Added for all elections endpoint
  current_status: string;
  has_voted: boolean;
  positions_count: number;
  candidates_count: number;
  created_at: string;
  updated_at: string;
}

export interface ElectionPosition {
  id: number;
  name: string;
  description: string | null;
  type: "single" | "multiple" | "ranked";
  max_selection: number | null;
  ranking_levels: number | null;
  allow_abstain: boolean;
  candidates: ElectionCandidate[];
}

export interface ElectionCandidate {
  id: number;
  user_id: number;
  user: {
    id: number;
    name: string;
    first_name: string;
    last_name: string;
    email: string;
    profile_photo: string | null;
  } | null;
  photo_url: string | null;
  tagline: string | null;
  bio: string | null;
  manifesto: string | null;
  approved: boolean;
  created_at: string;
}

export interface ElectionDetail extends Election {
  status: string;
  positions: ElectionPosition[];
}

export interface ActiveElectionsResponse {
  success: boolean;
  message: string;
  data: Election[];
  meta: {
    total: number;
    timestamp: string;
  };
}

export interface AllElectionsResponse {
  success: boolean;
  message: string;
  data: Election[];
  meta: {
    total: number;
    timestamp: string;
  };
}

export interface ElectionDetailResponse {
  success: boolean;
  message: string;
  data: ElectionDetail;
}

class ElectionService {
  /**
   * Get all elections for the authenticated student (active or not)
   */
  async getAllElections(): Promise<AllElectionsResponse> {
    const response = await api.get<AllElectionsResponse>("/students/elections");
    return response.data;
  }

  /**
   * Get active elections for the authenticated student
   */
  async getActiveElections(): Promise<ActiveElectionsResponse> {
    const response = await api.get<ActiveElectionsResponse>("/students/elections/active");
    return response.data;
  }

  /**
   * Get detailed information about a specific election
   */
  async getElection(id: number): Promise<ElectionDetailResponse> {
    const response = await api.get<ElectionDetailResponse>(`/students/elections/${id}`);
    return response.data;
  }
}

      export const electionService = new ElectionService();

      // Voting interfaces
      export interface BallotPosition {
        id: number;
        name: string;
        description: string | null;
        type: "single" | "multiple" | "ranked";
        max_selection: number | null;
        ranking_levels: number | null;
        allow_abstain: boolean;
        candidates: BallotCandidate[];
      }

      export interface BallotCandidate {
        id: number;
        user_id: number;
        user: {
          id: number;
          name: string;
          first_name: string;
          last_name: string;
          email: string;
          profile_photo: string | null;
        } | null;
        photo_url: string | null;
        tagline: string | null;
        bio: string | null;
        manifesto: string | null;
      }

      export interface BallotData {
        election: {
          id: number;
          title: string;
          description: string | null;
          type: string;
          current_status: string;
          start_time: string;
          end_time: string;
        };
        positions: BallotPosition[];
        has_voted: boolean;
        existing_vote: {
          vote_data: Record<string, unknown>;
          voted_at: string;
        } | null;
      }

      export interface BallotResponse {
        success: boolean;
        message: string;
        data: BallotData;
      }

      export interface CastVoteRequest {
        votes: {
          [key: string]: number | number[] | Array<{ candidate_id: number }> | boolean; // position votes or abstain flags
        };
      }

      export interface CastVoteResponse {
        success: boolean;
        message: string;
        data: {
          election_id: number;
          vote_id: number;
          voted_at: string;
        };
      }

      // My Votes (history)
      export interface MyVotePositionCandidate {
        id: number;
        user_id: number;
        user: {
          id: number;
          name: string;
          first_name: string;
          last_name: string;
          email: string;
          profile_photo: string | null;
        } | null;
        photo_url: string | null;
        tagline: string | null;
        bio: string | null;
        manifesto: string | null;
      }

      export interface MyVotePosition {
        id: number;
        name: string;
        description: string | null;
        type: "single" | "multiple" | "ranked";
        max_selection: number | null;
        ranking_levels: number | null;
        allow_abstain: boolean;
        candidates: MyVotePositionCandidate[];
      }

      export interface MyVoteElection {
        id: number;
        title: string;
        description: string | null;
        type: string;
        current_status: string;
        start_time: string | null;
        end_time: string | null;
      }

      export interface MyVoteEntry {
        election: MyVoteElection;
        voted_at: string | null;
        vote_data: Record<string, unknown>;
        positions: MyVotePosition[];
      }

      export interface MyVotesResponse {
        success: boolean;
        message: string;
        data: MyVoteEntry[];
      }

      class VoteService {
        /**
         * Get ballot data for an election (positions and candidates)
         */
        async getBallot(electionId: number): Promise<BallotResponse> {
          const response = await api.get<BallotResponse>(`/students/elections/${electionId}/ballot`);
          return response.data;
        }

        /**
         * Cast a vote for an election
         */
        async castVote(electionId: number, voteData: CastVoteRequest): Promise<CastVoteResponse> {
          const response = await api.post<CastVoteResponse>(
            `/students/elections/${electionId}/vote`,
            voteData
          );
          return response.data;
        }

        /**
         * Get voting history (elections the student has voted in)
         */
        async getMyVotes(): Promise<MyVotesResponse> {
          const response = await api.get<MyVotesResponse>("/students/votes");
          return response.data;
        }
      }

      export const voteService = new VoteService();

      // Analytics interfaces
      export interface AnalyticsData {
        overview: {
          total_elections: number;
          active_elections: number;
          upcoming_elections: number;
          closed_elections: number;
          total_votes: number;
          participation_rate: number;
        };
        votes_over_time: Array<{ date: string; count: number }>;
        election_types: Record<string, number>;
        voting_hours: Array<{ hour: number; count: number }>;
      }

      export interface AnalyticsResponse {
        success: boolean;
        message: string;
        data: AnalyticsData;
      }

      class AnalyticsService {
        /**
         * Get detailed analytics for the authenticated student
         */
        async getAnalytics(): Promise<AnalyticsResponse> {
          const response = await api.get<AnalyticsResponse>("/students/analytics");
          return response.data;
        }
      }

      export const analyticsService = new AnalyticsService();

      // Results interfaces
      export interface ElectionResult {
        election: {
          id: number;
          title: string;
          description: string | null;
          type: string;
          status: string;
          start_time: string;
          end_time: string;
        };
        total_votes: number;
        unique_voters: number;
        positions: PositionResult[];
      }

      export interface PositionResult {
        position_id: number;
        position_name: string;
        position_description: string | null;
        position_type: string;
        total_votes: number;
        valid_votes: number;
        abstentions: number;
        candidates: CandidateResult[];
        winners: CandidateResult[];
      }

      export interface CandidateResult {
        candidate_id: number;
        candidate_name: string;
        candidate_tagline: string | null;
        candidate_photo: string | null;
        votes: number;
        percentage: number;
        rank: number | null;
      }

      export interface ElectionResultsResponse {
        success: boolean;
        message: string;
        data: ElectionResult;
      }

      export interface AllResultsResponse {
        success: boolean;
        message: string;
        data: Array<{
          id: number;
          title: string;
          description: string | null;
          end_time: string;
          total_votes: number;
        }>;
      }

      class ResultsService {
        /**
         * Get results for a specific election
         */
        async getElectionResults(electionId: number): Promise<ElectionResultsResponse> {
          const response = await api.get<ElectionResultsResponse>(`/students/elections/${electionId}/results`);
          return response.data;
        }

        /**
         * Get all closed elections with results
         */
        async getAllResults(): Promise<AllResultsResponse> {
          try {
            console.log("Fetching all results from /students/elections/results");
            const response = await api.get<AllResultsResponse>("/students/elections/results");
            console.log("getAllResults response:", response.data);
            
            // Ensure response has the expected structure
            if (response.data && typeof response.data === 'object') {
              return response.data;
            }
            
            // If response structure is unexpected, return empty results
            return {
              success: true,
              message: "No results available",
              data: [],
            };
          } catch (error: any) {
            // Better error logging - handle all error types
            let errorMessage = "Unknown error";
            let errorStatus: number | undefined;
            let errorData: any = null;
            
            // Log the raw error first - safely
            try {
              console.error("getAllResults - Error message:", error?.message || "No message");
              console.error("getAllResults - Error type:", typeof error);
              console.error("getAllResults - Error constructor:", error?.constructor?.name);
              console.error("getAllResults - Is Axios Error:", error?.isAxiosError);
            } catch (e) {
              console.error("Could not log error details:", e);
            }
            
            // Check if it's an Axios error
            if (error?.isAxiosError) {
              errorMessage = error?.message || "Network error";
              errorStatus = error?.response?.status;
              
              // Safely extract error data
              try {
                errorData = error?.response?.data;
                if (errorData && typeof errorData === 'object') {
                  errorData = JSON.parse(JSON.stringify(errorData));
                }
              } catch {
                errorData = error?.response?.data ? String(error?.response?.data) : null;
              }
              
              const errorDetails: Record<string, any> = {
                message: errorMessage,
                status: errorStatus,
                statusText: error?.response?.statusText || "No status text",
                url: error?.config?.url || "Unknown URL",
                baseURL: error?.config?.baseURL || "Unknown baseURL",
                fullURL: error?.config ? `${error?.config.baseURL}${error?.config.url}` : "Unknown",
                code: error?.code || "No code",
              };
              
              if (errorData) {
                errorDetails.responseData = errorData;
              }
              
              console.error("getAllResults Axios error details:", errorDetails);
            } else if (error instanceof Error) {
              errorMessage = error.message;
              console.error("getAllResults Error object:", {
                name: error.name,
                message: error.message,
                stack: error.stack,
              });
            } else {
              // Try to extract information from the error
              errorMessage = error?.message || String(error) || "Unknown error";
              console.error("getAllResults Unknown error type:", {
                error,
                stringified: JSON.stringify(error, Object.getOwnPropertyNames(error)),
              });
            }
            
            // If 404 or 403, return empty results instead of throwing
            if (errorStatus === 404 || errorStatus === 403) {
              return {
                success: true,
                message: errorData?.message || "No results available",
                data: [],
              };
            }
            
            // If it's a network error or no response, return empty results
            if (!error?.response && error?.isAxiosError) {
              console.error("Network error - no response from server");
              return {
                success: false,
                message: "Unable to connect to server. Please check your connection and try again.",
                data: [],
              };
            }
            
            // For other errors, return error response with empty data
            return {
              success: false,
              message: errorData?.message || errorMessage || "Failed to load results",
              data: [],
            };
          }
        }
      }

      export const resultsService = new ResultsService();

