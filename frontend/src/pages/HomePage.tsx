import { useEffect, useState } from 'react';
import { backendApi } from '../lib/api';

type HealthResponse = {
  status: string;
  service: string;
};

function HomePage() {
  const [health, setHealth] = useState<HealthResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    backendApi
      .get<HealthResponse>('/api/v1/health')
      .then((response) => {
        setHealth(response.data);
        setError(null);
      })
      .catch(() => {
        setError('Backend health endpoint is not reachable yet.');
      });
  }, []);

  return (
    <section className="space-y-4">
      <h2 className="text-xl font-semibold">Development Foundation</h2>
      <p className="text-slate-700">
        This scaffold provides the frontend shell for FireGuard AI.
      </p>
      <div className="rounded-lg border border-slate-200 bg-white p-4">
        <h3 className="mb-2 font-medium">Backend health</h3>
        {health ? (
          <p className="text-emerald-700">
            {health.service}: {health.status}
          </p>
        ) : (
          <p className="text-slate-600">Checking health...</p>
        )}
        {error ? <p className="mt-2 text-amber-700">{error}</p> : null}
      </div>
    </section>
  );
}

export default HomePage;
