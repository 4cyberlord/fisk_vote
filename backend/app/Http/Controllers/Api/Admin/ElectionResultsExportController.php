<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Election;
use App\Services\ElectionResultsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Response;

class ElectionResultsExportController extends Controller
{
    protected ElectionResultsService $resultsService;

    public function __construct(ElectionResultsService $resultsService)
    {
        $this->resultsService = $resultsService;
    }

    /**
     * Export election results as CSV.
     *
     * GET /api/v1/admin/elections/{id}/results/export/csv
     */
    public function exportCsv(Request $request, $id)
    {
        try {
            $election = Election::find($id);

            if (!$election) {
                return response()->json([
                    'success' => false,
                    'message' => 'Election not found.',
                ], 404);
            }

            $results = $this->resultsService->calculateElectionResults($election);

            $filename = 'election-results-' . $election->id . '-' . now()->format('Y-m-d') . '.csv';
            $headers = [
                'Content-Type' => 'text/csv',
                'Content-Disposition' => "attachment; filename=\"{$filename}\"",
            ];

            $callback = function () use ($results) {
                $file = fopen('php://output', 'w');

                // Write election header
                fputcsv($file, ['Election Results']);
                fputcsv($file, ['Title', $results['election']['title']]);
                fputcsv($file, ['Total Votes', $results['total_votes']]);
                fputcsv($file, ['Unique Voters', $results['unique_voters']]);
                fputcsv($file, []); // Empty row

                // Write position results
                foreach ($results['positions'] as $position) {
                    fputcsv($file, ['Position', $position['position_name']]);
                    fputcsv($file, ['Total Votes', $position['total_votes']]);
                    fputcsv($file, ['Valid Votes', $position['valid_votes']]);
                    fputcsv($file, ['Abstentions', $position['abstentions']]);
                    fputcsv($file, []); // Empty row

                    // Write candidate results
                    fputcsv($file, ['Rank', 'Candidate', 'Votes', 'Percentage']);
                    foreach ($position['candidates'] as $candidate) {
                        fputcsv($file, [
                            $candidate['rank'] ?? '—',
                            $candidate['candidate_name'],
                            $candidate['votes'],
                            $candidate['percentage'] . '%',
                        ]);
                    }
                    fputcsv($file, []); // Empty row
                }

                fclose($file);
            };

            return Response::stream($callback, 200, $headers);
        } catch (\Exception $e) {
            Log::error('API Admin Export: Failed to export CSV', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'election_id' => $id,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to export results.',
                'error' => config('app.debug') ? $e->getMessage() : 'An unexpected error occurred',
            ], 500);
        }
    }
}

