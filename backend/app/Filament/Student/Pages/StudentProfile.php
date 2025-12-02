<?php

namespace App\Filament\Student\Pages;

use App\Models\Department;
use App\Models\Major;
use App\Models\Organization;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Actions\Action;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Illuminate\Contracts\Support\Htmlable;

class StudentProfile extends Page implements HasForms
{
    use InteractsWithForms;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-user-circle';

    protected string $view = 'filament.student.pages.student-profile';

    protected static ?string $navigationLabel = 'My Profile';

    protected static string|\UnitEnum|null $navigationGroup = null;

    protected static ?int $navigationSort = 1;

    protected static bool $shouldRegisterNavigation = true;

    public ?array $data = [];

    public function mount(): void
    {
        $user = auth()->user();

        $this->form->fill([
            // Personal Information
            'first_name' => $user->first_name,
            'middle_initial' => $user->middle_initial,
            'last_name' => $user->last_name,

            // Student Information
            'student_id' => $user->student_id,
            'email' => $user->email,
            'university_email' => $user->university_email,
            'personal_email' => $user->personal_email,
            'phone_number' => $user->phone_number,
            'profile_photo' => $user->profile_photo,
            'address' => $user->address,

            // Academic Information
            'department' => $user->department,
            'major' => $user->major,
            'class_level' => $user->class_level,
            'student_type' => $user->student_type,
            'citizenship_status' => $user->citizenship_status,

            // Relationships
            'organizations' => $user->organizations->pluck('id')->toArray(),
        ]);
    }

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Profile Photo')
                    ->schema([
                        FileUpload::make('profile_photo')
                            ->label('Profile Photo')
                            ->image()
                            ->imageEditor()
                            ->directory('profile-photos')
                            ->visibility('public')
                            ->maxSize(5120)
                            ->helperText('Upload your profile photo (Max: 5MB)')
                            ->columnSpanFull(),
                    ])
                    ->collapsible(),

                Section::make('Personal Information')
                    ->schema([
                        TextInput::make('first_name')
                            ->label('First Name')
                            ->required()
                            ->maxLength(255)
                            ->disabled()
                            ->helperText('Managed by administrators'),

                        TextInput::make('middle_initial')
                            ->label('Middle Initial')
                            ->maxLength(1)
                            ->disabled()
                            ->helperText('Managed by administrators'),

                        TextInput::make('last_name')
                            ->label('Last Name')
                            ->required()
                            ->maxLength(255)
                            ->disabled()
                            ->helperText('Managed by administrators'),
                    ])
                    ->columns(3)
                    ->description('Name fields are managed by administrators'),

                Section::make('Student Information')
                    ->schema([
                        TextInput::make('student_id')
                            ->label('Student ID')
                            ->disabled()
                            ->helperText('Your unique student identification number'),

                        TextInput::make('email')
                            ->label('Fisk Email')
                            ->email()
                            ->disabled()
                            ->helperText('Your official Fisk University email address'),

                        TextInput::make('university_email')
                            ->label('University Email (Alternative)')
                            ->email()
                            ->disabled()
                            ->helperText('Alternative university email if different'),

                        TextInput::make('personal_email')
                            ->label('Personal Email')
                            ->email()
                            ->helperText('Optional personal email address (you can edit this)'),

                        TextInput::make('phone_number')
                            ->label('Phone Number')
                            ->tel()
                            ->helperText('Optional phone number (you can edit this)'),

                        Textarea::make('address')
                            ->label('Address')
                            ->rows(3)
                            ->helperText('Optional address information (you can edit this)')
                            ->columnSpanFull(),
                    ])
                    ->columns(2)
                    ->description('Student identification and contact information'),

                Section::make('Academic Information')
                    ->schema([
                        Select::make('department')
                            ->label('Department / Program')
                            ->options(Department::query()->pluck('name', 'name'))
                            ->searchable()
                            ->preload()
                            ->createOptionForm([
                                TextInput::make('name')
                                    ->label('Department Name')
                                    ->required()
                                    ->unique('departments', 'name')
                                    ->maxLength(255),
                            ])
                            ->createOptionUsing(function (array $data): string {
                                $department = Department::create($data);
                                return $department->name;
                            })
                            ->helperText('Select your department or create a new one (you can edit this)'),

                        Select::make('major')
                            ->label('Major')
                            ->options(Major::query()->pluck('name', 'name'))
                            ->searchable()
                            ->preload()
                            ->createOptionForm([
                                TextInput::make('name')
                                    ->label('Major/Minor Name')
                                    ->required()
                                    ->unique('majors', 'name')
                                    ->maxLength(255),
                            ])
                            ->createOptionUsing(function (array $data): string {
                                $major = Major::create($data);
                                return $major->name;
                            })
                            ->helperText('Select your major or create a new one (you can edit this)'),

                        Select::make('class_level')
                            ->label('Class Level')
                            ->options([
                                'Freshman' => 'Freshman',
                                'Sophomore' => 'Sophomore',
                                'Junior' => 'Junior',
                                'Senior' => 'Senior',
                            ])
                            ->helperText('Select your current class level (you can edit this)'),

                        Select::make('student_type')
                            ->label('Student Type')
                            ->options([
                                'Undergraduate' => 'Undergraduate',
                                'Graduate' => 'Graduate',
                                'Transfer' => 'Transfer',
                                'International' => 'International',
                            ])
                            ->helperText('Select your student type (you can edit this)'),

                        TextInput::make('citizenship_status')
                            ->label('Citizenship Status')
                            ->maxLength(255)
                            ->helperText('Enter your citizenship status (you can edit this)'),
                    ])
                    ->columns(2)
                    ->description('Academic information'),

                Section::make('Organizations / Clubs')
                    ->schema([
                        Select::make('organizations')
                            ->label('Organizations / Clubs')
                            ->multiple()
                            ->options(Organization::query()->pluck('name', 'id'))
                            ->searchable()
                            ->preload()
                            ->helperText('Select organizations or clubs you are part of (you can edit this)')
                            ->columnSpanFull(),
                    ])
                    ->collapsible()
                    ->description('Your organizational memberships'),
            ])
            ->statePath('data');
    }

    public function getTitle(): string | Htmlable
    {
        return 'My Profile';
    }

    public function getHeading(): string | Htmlable
    {
        return 'My Profile';
    }

    public function getSubheading(): string | Htmlable | null
    {
        return 'View and update your profile information';
    }

    public function save(): void
    {
        $data = $this->form->getState();
        $user = auth()->user();

        // Update editable user profile fields
        $user->update([
            'personal_email' => $data['personal_email'] ?? null,
            'phone_number' => $data['phone_number'] ?? null,
            'profile_photo' => $data['profile_photo'] ?? null,
            'address' => $data['address'] ?? null,
            'department' => $data['department'] ?? null,
            'major' => $data['major'] ?? null,
            'class_level' => $data['class_level'] ?? null,
            'student_type' => $data['student_type'] ?? null,
            'citizenship_status' => $data['citizenship_status'] ?? null,
        ]);

        // Sync organizations
        if (isset($data['organizations'])) {
            $user->organizations()->sync($data['organizations']);
        } else {
            $user->organizations()->sync([]);
        }

        Notification::make()
            ->title('Profile Updated')
            ->body('Your profile has been successfully updated.')
            ->success()
            ->send();
    }

    protected function getFormActions(): array
    {
        return [
            Action::make('save')
                ->label('Save Changes')
                ->submit('save')
                ->color('primary'),
        ];
    }

    protected function hasFullWidthFormActions(): bool
    {
        return false;
    }
}
