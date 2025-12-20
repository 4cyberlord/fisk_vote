      "use client";

      import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  electionService,
  Election,
  ElectionDetail,
  voteService,
  CastVoteRequest,
  MyVotesResponse,
  analyticsService,
  AnalyticsData,
  resultsService,
  ElectionResult,
  turnoutService,
  ElectionTurnout,
  votingStatsService,
  VotingStatsResponse,
} from "@/services/electionService";
import { setServerTime } from "@/lib/timeService";

/**
 * Hook to get all elections (active or not)
 */
export function useAllElections() {
  return useQuery({
    queryKey: ["elections", "all"],
    queryFn: async () => {
      const response = await electionService.getAllElections();
      setServerTime(response.meta?.server_time);
      return response.data; // Returns Election[]
    },
    staleTime: 30 * 1000, // 30 seconds - refresh frequently to catch status changes
    refetchInterval: 60 * 1000, // Refetch every minute to catch when elections open/close
    retry: 1,
  });
}

/**
 * Hook to get active elections
 */
export function useActiveElections() {
  return useQuery({
    queryKey: ["elections", "active"],
    queryFn: async () => {
      const response = await electionService.getActiveElections();
      setServerTime(response.meta?.server_time);
      return response.data; // Returns Election[]
    },
    staleTime: 15 * 1000, // 15 seconds - refresh very frequently to catch status changes
    refetchInterval: 30 * 1000, // Refetch every 30 seconds to catch when elections open
    retry: 1,
  });
}

      /**
       * Hook to get a specific election by ID
       */
      export function useElection(id: number | null) {
        return useQuery({
          queryKey: ["elections", id],
          queryFn: async () => {
            if (!id) return null;
            const response = await electionService.getElection(id);
      setServerTime(response.meta?.server_time);
            return response.data; // Returns ElectionDetail
          },
          enabled: !!id, // Only run if id is provided
          staleTime: 2 * 60 * 1000, // 2 minutes
          retry: 1,
        });
      }

      /**
       * Hook to get ballot data for voting
       */
      export function useBallot(electionId: number | null) {
        return useQuery({
          queryKey: ["ballot", electionId],
          queryFn: async () => {
            if (!electionId) return null;
            const response = await voteService.getBallot(electionId);
      // Ballot responses may carry server_time in meta if added later; defensive set
      // @ts-expect-error meta may exist depending on backend response
      setServerTime(response.meta?.server_time);
            return response.data; // Returns BallotData
          },
          enabled: !!electionId,
          staleTime: 1 * 60 * 1000, // 1 minute - ballot data should be fresh
          retry: 1,
        });
      }

      /**
       * Hook to get the current student's voting history
       */
      export function useMyVotes() {
        return useQuery({
          queryKey: ["votes", "mine"],
          queryFn: async (): Promise<MyVotesResponse["data"]> => {
            const response = await voteService.getMyVotes();
            return response.data;
          },
          staleTime: 1 * 60 * 1000,
          retry: 1,
        });
      }

      /**
       * Hook to cast a vote
       */
      export function useCastVote() {
        const queryClient = useQueryClient();

        return useMutation({
          mutationFn: async ({
            electionId,
            voteData,
          }: {
            electionId: number;
            voteData: CastVoteRequest;
          }) => {
            const response = await voteService.castVote(electionId, voteData);
            return response;
          },
          onSuccess: (data, variables) => {
            // Invalidate related queries
            queryClient.invalidateQueries({ queryKey: ["elections"] });
            queryClient.invalidateQueries({ queryKey: ["ballot", variables.electionId] });
            queryClient.invalidateQueries({ queryKey: ["elections", variables.electionId] });
          },
        });
      }

      /**
       * Hook to get analytics data for the authenticated student
       */
      export function useAnalytics() {
        return useQuery<AnalyticsData, Error>({
          queryKey: ["analytics"],
          queryFn: async () => {
            const response = await analyticsService.getAnalytics();
            return response.data;
          },
          staleTime: 5 * 60 * 1000, // 5 minutes
          retry: 1,
        });
      }

      /**
       * Hook to get election results
       */
      export function useElectionResults(electionId: number | null) {
        return useQuery<ElectionResult, Error>({
          queryKey: ["election-results", electionId],
          queryFn: async () => {
            if (!electionId) return null as any;
            const response = await resultsService.getElectionResults(electionId);
            return response.data;
          },
          enabled: !!electionId,
          staleTime: 2 * 60 * 1000, // 2 minutes
          retry: 1,
        });
      }

      /**
       * Hook to get all available results
       */
      export function useAllResults() {
        return useQuery({
          queryKey: ["all-results"],
          queryFn: async () => {
            try {
              const response = await resultsService.getAllResults();
              
              // Handle response - check if it's successful
              if (response.success === false) {
                // If the service returned an error response, show message but return empty array
                console.warn("Results service returned error:", response.message);
                return [];
              }
              
              // Return the data array (could be empty)
              return response.data || [];
            } catch (error: any) {
              console.error("Error in useAllResults hook:", error);
              // Always return empty array instead of throwing to prevent error state
              // The UI will show "No Results Available" message
              return [];
            }
          },
          staleTime: 2 * 60 * 1000, // 2 minutes
          retry: 1,
          onError: (error) => {
            console.error("useAllResults query error:", error);
          },
        });
      }

      /**
       * Hook to get turnout statistics for a specific election
       */
      export function useElectionTurnout(
        electionId: number | null,
        includeBreakdown: boolean = false
      ) {
        return useQuery<ElectionTurnout, Error>({
          queryKey: ["election-turnout", electionId, includeBreakdown],
          queryFn: async () => {
            if (!electionId) return null as any;
            const response = await turnoutService.getElectionTurnout(
              electionId,
              includeBreakdown
            );
            return response.data;
          },
          enabled: !!electionId,
          staleTime: 30 * 1000, // 30 seconds for active elections
          retry: 1,
        });
      }

      /**
       * Hook to get turnout statistics for all elections
       */
      export function useAllElectionsTurnout() {
        const { data: elections } = useAllElections();

        return useQuery<
          Array<{ election: Election; turnout: ElectionTurnout | null }>,
          Error
        >({
          queryKey: ["all-elections-turnout", elections?.map((e) => e.id)],
          queryFn: async () => {
            if (!elections || elections.length === 0) return [];

            // Fetch turnout for all elections in parallel
            const turnoutPromises = elections.map(async (election) => {
              try {
                const response = await turnoutService.getElectionTurnout(
                  election.id,
                  false
                );
                return { election, turnout: response.data };
              } catch (error) {
                console.error(
                  `Failed to fetch turnout for election ${election.id}:`,
                  error
                );
                return { election, turnout: null };
              }
            });

            return Promise.all(turnoutPromises);
          },
          enabled: !!elections && elections.length > 0,
          staleTime: 30 * 1000, // 30 seconds
          retry: 1,
        });
      }

      /**
       * Hook to get voting statistics for the authenticated student
       */
      export function useVotingStats() {
        return useQuery<VotingStatsResponse["data"], Error>({
          queryKey: ["voting-stats"],
          queryFn: async () => {
            const response = await votingStatsService.getVotingStats();
            return response.data;
          },
          staleTime: 2 * 60 * 1000, // 2 minutes
          retry: 1,
        });
      }

