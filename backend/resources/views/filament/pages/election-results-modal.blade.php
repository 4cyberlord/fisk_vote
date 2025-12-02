<style>
    .election-results-modal {
        --space-y: 1rem;
        max-height: 70vh;
        overflow-y: auto;
    }
    .election-results-modal > * + * {
        margin-top: var(--space-y);
    }
    .election-results-stats-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 0.75rem;
    }
    .election-results-stat-card {
        padding: 0.75rem;
        border-radius: 0.5rem;
        border-width: 1px;
    }
    .election-results-stat-card-blue {
        background-color: #eff6ff;
        border-color: #dbeafe;
    }
    .election-results-stat-card-emerald {
        background-color: #ecfdf5;
        border-color: #d1fae5;
    }
    .election-results-stat-card-amber {
        background-color: #fffbeb;
        border-color: #fef3c7;
    }
    .election-results-stat-label {
        font-size: 0.75rem;
        color: #6b7280;
        margin-bottom: 0.25rem;
    }
    .election-results-stat-value {
        font-size: 1.5rem;
        font-weight: 700;
        color: #111827;
    }
    .election-results-position {
        margin-bottom: 1.5rem;
    }
    .election-results-position-header {
        font-size: 1rem;
        font-weight: 600;
        color: #111827;
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 0.5rem;
    }
    .election-results-position-badge {
        padding: 0.125rem 0.5rem;
        font-size: 0.65rem;
        border-radius: 0.25rem;
        text-transform: uppercase;
        background-color: #eff6ff;
        color: #1e40af;
        font-weight: 700;
        border: 1px solid #bfdbfe;
    }
    .election-results-winners {
        margin-top: 0.75rem;
        padding: 0.75rem;
        border-radius: 0.5rem;
        border: 1px solid #6ee7b7;
        background-color: #ecfdf5;
    }
    .election-results-winners-title {
        font-weight: 600;
        color: #065f46;
        font-size: 0.875rem;
        margin-bottom: 0.5rem;
    }
    .election-results-winner-card {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0.5rem;
        background-color: #ffffff;
        border-radius: 0.375rem;
        border: 1px solid #e5e7eb;
    }
    .election-results-winner-name {
        font-weight: 700;
        color: #111827;
        font-size: 0.875rem;
    }
    .election-results-winner-votes {
        color: #047857;
        font-weight: 700;
        font-size: 0.875rem;
        text-align: right;
    }
    .election-results-winner-percentage {
        font-size: 0.75rem;
        color: #6b7280;
        text-align: right;
    }
    .election-results-table {
        margin-top: 0.75rem;
        overflow: hidden;
        border: 1px solid #e5e7eb;
        border-radius: 0.5rem;
    }
    .election-results-table table {
        width: 100%;
        font-size: 0.8125rem;
        text-align: left;
    }
    .election-results-table thead {
        background-color: #f3f4f6;
        color: #4b5563;
        font-size: 0.6875rem;
        text-transform: uppercase;
        font-weight: 600;
    }
    .election-results-table th {
        padding: 0.5rem 0.75rem;
    }
    .election-results-table tbody {
        background-color: #ffffff;
    }
    .election-results-table tbody tr {
        border-top: 1px solid #e5e7eb;
    }
    .election-results-table tbody tr:hover {
        background-color: #f9fafb;
    }
    .election-results-table tbody tr.winner-row {
        background-color: #ecfdf5;
    }
    .election-results-table td {
        padding: 0.5rem 0.75rem;
    }
    .election-results-rank-badge {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        height: 1.5rem;
        width: 1.5rem;
        border-radius: 0.25rem;
        background-color: #059669;
        color: #ffffff;
        font-weight: 600;
        font-size: 0.75rem;
    }
    .election-results-candidate-name {
        font-weight: 600;
        color: #111827;
        font-size: 0.8125rem;
    }
    .election-results-votes-winner {
        color: #047857;
        font-weight: 700;
        text-align: right;
    }
    .election-results-votes-normal {
        color: #111827;
        font-weight: 700;
        text-align: right;
    }
    .election-results-percentage-winner {
        color: #047857;
        font-weight: 600;
        text-align: right;
    }
    .election-results-percentage-normal {
        color: #111827;
        font-weight: 600;
        text-align: right;
    }
    .election-results-empty {
        text-align: center;
        padding: 1.5rem 0;
        color: #6b7280;
        font-size: 0.875rem;
    }
</style>

<div class="election-results-modal">
    <!-- Stats Grid -->
    <div class="election-results-stats-grid">
        <div class="election-results-stat-card election-results-stat-card-blue">
            <p class="election-results-stat-label">Total Votes</p>
            <p class="election-results-stat-value">{{ $results['total_votes'] ?? 0 }}</p>
        </div>

        <div class="election-results-stat-card election-results-stat-card-emerald">
            <p class="election-results-stat-label">Unique Voters</p>
            <p class="election-results-stat-value">{{ $results['unique_voters'] ?? 0 }}</p>
        </div>

        <div class="election-results-stat-card election-results-stat-card-amber">
            <p class="election-results-stat-label">Positions</p>
            <p class="election-results-stat-value">
                {{ count($results['positions'] ?? []) }}
            </p>
        </div>
    </div>

    <!-- POSITIONS LOOP -->
    @foreach ($results['positions'] ?? [] as $position)
        <div class="election-results-position">
            <!-- Position Header -->
            <h3 class="election-results-position-header">
                <span>{{ $position['position_name'] }}</span>
                <span class="election-results-position-badge">
                    {{ ucfirst($position['position_type']) }}
                </span>
            </h3>

            <!-- Winners Section -->
            @if (!empty($position['winners']))
                <div class="election-results-winners">
                    <h4 class="election-results-winners-title">
                        Winner{{ count($position['winners']) > 1 ? 's' : '' }}
                    </h4>

                    @foreach ($position['winners'] as $winner)
                        <div class="election-results-winner-card" style="{{ !$loop->last ? 'margin-bottom: 0.5rem;' : '' }}">
                            <div>
                                <p class="election-results-winner-name">
                                    {{ $winner['candidate_name'] }}
                                </p>
                            </div>

                            <div>
                                <p class="election-results-winner-votes">
                                    {{ $winner['votes'] }} vote{{ $winner['votes'] != 1 ? 's' : '' }}
                                </p>
                                <p class="election-results-winner-percentage">
                                    {{ $winner['percentage'] }}%
                                </p>
                            </div>
                        </div>
                    @endforeach
                </div>
            @endif

            <!-- Candidates Table -->
            <div class="election-results-table">
                <table>
                    <thead>
                        <tr>
                            <th>Rank</th>
                            <th>Candidate</th>
                            <th style="text-align: right;">Votes</th>
                            <th style="text-align: right;">%</th>
                        </tr>
                    </thead>

                    <tbody>
                        @foreach ($position['candidates'] as $candidate)
                            @php
                                $isWinner =
                                    !empty($position['winners']) &&
                                    in_array(
                                        $candidate['candidate_id'],
                                        array_column($position['winners'], 'candidate_id'),
                                    );
                            @endphp

                            <tr class="{{ $isWinner ? 'winner-row' : '' }}">
                                <td>
                                    @if ($candidate['rank'])
                                        <span class="election-results-rank-badge">
                                            {{ $candidate['rank'] }}
                                        </span>
                                    @else
                                        <span style="color: #9ca3af; font-size: 0.75rem;">—</span>
                                    @endif
                                </td>

                                <td>
                                    <span class="election-results-candidate-name">
                                        {{ $candidate['candidate_name'] }}
                                    </span>
                                </td>

                                <td class="{{ $isWinner ? 'election-results-votes-winner' : 'election-results-votes-normal' }}">
                                    {{ $candidate['votes'] }}
                                </td>

                                <td class="{{ $isWinner ? 'election-results-percentage-winner' : 'election-results-percentage-normal' }}">
                                    {{ $candidate['percentage'] }}%
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    @endforeach

    <!-- No positions -->
    @if (empty($results['positions']))
        <div class="election-results-empty">
            <p>No positions found for this election.</p>
        </div>
    @endif
</div>
