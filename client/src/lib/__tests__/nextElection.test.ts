import { describe, expect, it } from "vitest";
import { findNextElection } from "../../hooks/useNextElection";
import type { PublicElection } from "../../hooks/usePublicElections";

const baseElection: PublicElection = {
  id: 1,
  title: "Test Election",
  description: null,
  type: "single",
  start_time: null,
  end_time: null,
  start_timestamp: null,
  end_timestamp: null,
  status: "Upcoming",
  current_status: "Upcoming",
  positions_count: 1,
  candidates_count: 1,
};

describe("findNextElection", () => {
  it("returns earliest upcoming election when multiple future dates exist", () => {
    const now = 1_000;
    const elections: PublicElection[] = [
      { ...baseElection, id: 1, title: "Later", start_timestamp: now + 5000 },
      { ...baseElection, id: 2, title: "Sooner", start_timestamp: now + 2000 },
    ];

    const result = findNextElection(elections, now);

    expect(result.election?.id).toBe(2);
    expect(result.targetTimestamp).toBe(now + 2000);
    expect(result.state).toBe("upcoming");
  });

  it("returns none when no upcoming elections remain", () => {
    const now = 10_000;
    const elections: PublicElection[] = [
      { ...baseElection, id: 1, title: "Past", start_timestamp: now - 100 },
    ];

    const result = findNextElection(elections, now);

    expect(result.election).toBeNull();
    expect(result.state).toBe("none");
    expect(result.targetTimestamp).toBeNull();
  });
});

