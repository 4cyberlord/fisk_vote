<?php

namespace App\Filament\Resources\Elections\Pages;

use App\Filament\Resources\Elections\ElectionResource;
use App\Services\ElectionResultsService;
use Filament\Actions\Action;
use Filament\Resources\Pages\ViewRecord;

class ViewElection extends ViewRecord
{
    protected static string $resource = ElectionResource::class;

    protected function getHeaderActions(): array
    {
        $resultsService = app(ElectionResultsService::class);
        
        return [
            Action::make('view_results')
                ->label('View Results')
                ->icon('heroicon-o-chart-bar')
                ->color('success')
                ->modalHeading(fn () => "Results: {$this->record->title}")
                ->modalDescription(fn () => "Election ended on " . $this->record->end_time->format('F j, Y \a\t g:i A'))
                ->modalContent(fn () => view('filament.pages.election-results-modal', [
                    'results' => $resultsService->calculateElectionResults($this->record),
                ]))
                ->modalWidth('5xl')
                ->modalSubmitAction(false)
                ->modalCancelActionLabel('Close')
                ->visible(fn () => $this->record->current_status === 'Closed'),
            
            Action::make('export_csv')
                ->label('Export CSV')
                ->icon('heroicon-o-arrow-down-tray')
                ->color('info')
                ->action(function () {
                    $controller = app(\App\Http\Controllers\Api\Admin\ElectionResultsExportController::class);
                    return $controller->exportCsv(request(), $this->record->id);
                })
                ->visible(fn () => $this->record->current_status === 'Closed'),
        ];
    }
}
