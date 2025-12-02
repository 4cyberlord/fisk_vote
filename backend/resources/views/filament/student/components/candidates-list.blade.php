@php
    $election = $election ?? ($getRecord() ?? null);

    if (!$election) {
        echo '<div class="p-4 text-center text-gray-500 dark:text-gray-400">Election data not available</div>';
        return;
    }

    $candidates = \App\Models\ElectionCandidate::where('election_id', $election->id)
        ->where('approved', true)
        ->with(['user', 'position'])
        ->get()
        ->groupBy(function ($candidate) {
            return $candidate->position ? $candidate->position->name : 'Unknown Position';
        });

    $getPhotoUrl = function ($candidate) {
        $photoUrl = null;
        $storage = \Illuminate\Support\Facades\Storage::disk('public');

        if ($candidate->photo_url) {
            if (filter_var($candidate->photo_url, FILTER_VALIDATE_URL)) {
                $photoUrl = $candidate->photo_url;
            } elseif ($storage->exists($candidate->photo_url)) {
                $photoUrl = $storage->url($candidate->photo_url);
            } else {
                $photoUrl = asset('storage/' . $candidate->photo_url);
            }
        }

        if (!$photoUrl && $candidate->user->profile_photo) {
            if (filter_var($candidate->user->profile_photo, FILTER_VALIDATE_URL)) {
                $photoUrl = $candidate->user->profile_photo;
            } elseif ($storage->exists($candidate->user->profile_photo)) {
                $photoUrl = $storage->url($candidate->user->profile_photo);
            } else {
                $photoUrl = asset('storage/' . $candidate->user->profile_photo);
            }
        }

        if (!$photoUrl) {
            $photoUrl =
                'https://ui-avatars.com/api/?name=' .
                urlencode($candidate->user->full_name) .
                '&background=6366f1&color=fff&size=200&bold=true';
        }

        return $photoUrl;
    };
@endphp

@if ($candidates->isEmpty())
    <div class="flex flex-col items-center justify-center py-20 px-4">
        <div class="w-24 h-24 rounded-full bg-gray-100 dark:bg-gray-800 flex items-center justify-center mb-6">
            <svg class="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z">
                </path>
            </svg>
        </div>
        <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">No Candidates Available</h3>
        <p class="text-gray-500 dark:text-gray-400 text-center max-w-md">
            There are no approved candidates for this election position yet.
        </p>
    </div>
@else
    <div class="space-y-8 -mx-4 sm:-mx-6">
        @foreach ($candidates as $positionName => $positionCandidates)
            <div class="w-full px-4 sm:px-6">
                {{-- Position Header --}}
                <div class="mb-4">
                    <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-1">
                        {{ $positionName }}
                    </h2>
                    <p class="text-sm text-gray-500 dark:text-gray-400">
                        {{ count($positionCandidates) }} candidate{{ count($positionCandidates) !== 1 ? 's' : '' }}
                    </p>
                </div>

                {{-- Candidates Grid Container --}}
                <div
                    class="p-6 bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 shadow-sm">
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                        @foreach ($positionCandidates as $candidate)
                            @if (!$candidate->user)
                                @continue
                            @endif

                            @php
                                $photoUrl = $getPhotoUrl($candidate);
                                $user = $candidate->user;
                                $email = $user->university_email ?: $user->email;
                                $description =
                                    $candidate->tagline ?:
                                    ($candidate->bio
                                        ? \Str::limit($candidate->bio, 50)
                                        : ($user->department
                                            ? $user->department
                                            : 'Candidate'));
                            @endphp

                            {{-- Candidate Card --}}
                            <div
                                class="bg-gray-50 dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-700 p-5 hover:shadow-md transition-shadow">
                                <div class="flex justify-between items-start gap-3">
                                    <div class="flex-1 min-w-0">
                                        <h3 class="text-gray-900 dark:text-white text-lg font-semibold mb-1.5">
                                            {{ $user->full_name }}
                                        </h3>
                                        <span
                                            class="inline-block mb-2 px-3 py-0.5 text-xs font-medium rounded-full bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300">
                                            {{ $positionName }}
                                        </span>
                                        <p class="mt-2 text-sm text-gray-600 dark:text-gray-400 line-clamp-2">
                                            {{ $description }}
                                        </p>
                                    </div>
                                    <img src="{{ $photoUrl }}" alt="{{ $user->full_name }}"
                                        class="w-12 h-12 rounded-full object-cover border-2 border-gray-200 dark:border-gray-700 flex-shrink-0"
                                        onerror="this.src='https://ui-avatars.com/api/?name={{ urlencode($user->full_name) }}&background=6366f1&color=fff&size=200&bold=true'">
                                </div>
                                <div
                                    class="mt-5 grid grid-cols-2 gap-0 divide-x divide-gray-200 dark:divide-gray-700 border-t border-gray-200 dark:border-gray-700 pt-4">
                                    <div class="pr-3">
                                        @if ($email)
                                            <a href="mailto:{{ $email }}"
                                                class="flex items-center justify-center gap-2 text-sm text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors">
                                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                                    <path
                                                        d="M3 4a2 2 0 0 0-2 2v1.161l8.441 4.221a1.25 1.25 0 0 0 1.118 0L19 7.162V6a2 2 0 0 0-2-2H3Z">
                                                    </path>
                                                    <path
                                                        d="m19 8.839-7.77 3.885a2.75 2.75 0 0 1-2.46 0L1 8.839V14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V8.839Z">
                                                    </path>
                                                </svg>
                                                <span>Email</span>
                                            </a>
                                        @else
                                            <div
                                                class="flex items-center justify-center gap-2 text-sm text-gray-400 dark:text-gray-600">
                                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                                    <path
                                                        d="M3 4a2 2 0 0 0-2 2v1.161l8.441 4.221a1.25 1.25 0 0 0 1.118 0L19 7.162V6a2 2 0 0 0-2-2H3Z">
                                                    </path>
                                                    <path
                                                        d="m19 8.839-7.77 3.885a2.75 2.75 0 0 1-2.46 0L1 8.839V14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V8.839Z">
                                                    </path>
                                                </svg>
                                                <span>Email</span>
                                            </div>
                                        @endif
                                    </div>
                                    <div class="pl-3">
                                        <button type="button"
                                            class="flex items-center justify-center gap-2 w-full text-sm text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors">
                                            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" clip-rule="evenodd"
                                                    d="M2 3.5A1.5 1.5 0 0 1 3.5 2h1.148a1.5 1.5 0 0 1 1.465 1.175l.716 3.223a1.5 1.5 0 0 1-1.052 1.767l-.933.267c-.41.117-.643.555-.48.95a11.542 11.542 0 0 0 6.254 6.254c.395.163.833-.07.95-.48l.267-.933a1.5 1.5 0 0 1 1.767-1.052l3.223.716A1.5 1.5 0 0 1 18 15.352V16.5a1.5 1.5 0 0 1-1.5 1.5H15c-1.149 0-2.263-.15-3.326-.43A13.022 13.022 0 0 1 2.43 8.326 13.019 13.019 0 0 1 2 5V3.5Z">
                                                </path>
                                            </svg>
                                            <span>View</span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>
            </div>
        @endforeach
    </div>
@endif
