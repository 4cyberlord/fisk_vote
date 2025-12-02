# How to Use the Active Elections API

## API Route

**Endpoint:** `GET /api/v1/students/elections/active`

**Full URL:** `http://localhost:8000/api/v1/students/elections/active`

**Authentication:** Required (JWT Bearer Token in Authorization header)

---

## Frontend Usage

### 1. Using the React Hook (Recommended)

The easiest way to fetch active elections is using the `useActiveElections` hook:

```typescript
import { useActiveElections } from "@/hooks/useElections";

function MyComponent() {
  const { data: elections, isLoading, error } = useActiveElections();

  if (isLoading) {
    return <div>Loading elections...</div>;
  }

  if (error) {
    return <div>Error loading elections</div>;
  }

  return (
    <div>
      <h2>Active Elections ({elections?.length || 0})</h2>
      {elections?.map((election) => (
        <div key={election.id}>
          <h3>{election.title}</h3>
          <p>{election.description}</p>
          <p>Status: {election.current_status}</p>
          <p>Has Voted: {election.has_voted ? "Yes" : "No"}</p>
        </div>
      ))}
    </div>
  );
}
```

### 2. Using the Service Directly

```typescript
import { electionService } from "@/services/electionService";

async function fetchElections() {
  try {
    const response = await electionService.getActiveElections();
    const elections = response.data;
    console.log("Active elections:", elections);
  } catch (error) {
    console.error("Failed to fetch elections:", error);
  }
}
```

### 3. Using Axios Directly

```typescript
import { api } from "@/lib/axios";

async function fetchElections() {
  try {
    const response = await api.get("/students/elections/active");
    const elections = response.data.data;
    console.log("Active elections:", elections);
  } catch (error) {
    console.error("Failed to fetch elections:", error);
  }
}
```

---

## Response Structure

```typescript
{
  success: true,
  message: "Active elections retrieved successfully.",
  data: [
    {
      id: 1,
      title: "Student Government Election 2024",
      description: "Annual student government election",
      type: "multiple",
      max_selection: 3,
      ranking_levels: null,
      allow_write_in: false,
      allow_abstain: true,
      start_time: "2024-01-15T08:00:00Z",
      end_time: "2024-01-20T18:00:00Z",
      current_status: "Open",
      has_voted: false,
      positions_count: 5,
      candidates_count: 15,
      created_at: "2024-01-01T00:00:00Z",
      updated_at: "2024-01-10T00:00:00Z"
    }
  ],
  meta: {
    total: 1,
    timestamp: "2024-01-16T12:00:00Z"
  }
}
```

---

## Testing with cURL

```bash
# Replace YOUR_JWT_TOKEN with your actual JWT token
curl -X GET "http://localhost:8000/api/v1/students/elections/active" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Accept: application/json"
```

---

## Testing with Postman

1. **Method:** GET
2. **URL:** `http://localhost:8000/api/v1/students/elections/active`
3. **Headers:**
   - `Authorization: Bearer YOUR_JWT_TOKEN`
   - `Accept: application/json`
4. **Body:** None

---

## Get Single Election Details

To get detailed information about a specific election (including positions and candidates):

```typescript
import { useElection } from "@/hooks/useElections";

function ElectionDetails({ electionId }: { electionId: number }) {
  const { data: election, isLoading, error } = useElection(electionId);

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error loading election</div>;
  if (!election) return <div>Election not found</div>;

  return (
    <div>
      <h1>{election.title}</h1>
      <p>{election.description}</p>
      <h2>Positions</h2>
      {election.positions.map((position) => (
        <div key={position.id}>
          <h3>{position.name}</h3>
          <p>Candidates: {position.candidates.length}</p>
        </div>
      ))}
    </div>
  );
}
```

**Route:** `GET /api/v1/students/elections/{id}`

---

## Notes

- The API automatically filters elections based on:
  - Status must be `'active'`
  - Current time must be between `start_time` and `end_time`
  - User must be eligible (based on `is_universal` or `eligible_groups`)

- The JWT token is automatically included in requests via the axios interceptor (configured in `client/src/lib/axios.ts`)

- The hook uses React Query for caching and automatic refetching

