<div class="space-y-2">
    <label for="photo_file" class="block text-sm font-medium text-gray-900">
        {{ $getLabel() ?? 'Candidate Photo' }}
    </label>

    <div class="flex items-center gap-3">
        <label
            for="photo_file"
            class="inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-medium text-gray-700 border border-gray-300 shadow-sm cursor-pointer hover:bg-gray-50"
        >
            <svg class="mr-2 h-4 w-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1M12 4v12m0-12l-4 4m4-4l4 4"/>
            </svg>
            Choose file
        </label>

        <span class="text-sm text-gray-500">
            No file chosen
        </span>

        <input
            type="file"
            name="photo_file"
            id="photo_file"
            accept="image/jpeg,image/jpg,image/png,image/svg+xml"
            class="hidden"
        />
    </div>

    <p class="text-xs text-gray-500">
        JPG, PNG, or SVG. Maximum size 100MB.
    </p>
</div>
