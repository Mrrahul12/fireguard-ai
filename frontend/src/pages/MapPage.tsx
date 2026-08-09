import { useEffect, useRef } from 'react';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

function MapPage() {
  const mapRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (!mapRef.current) {
      return;
    }

    const map = L.map(mapRef.current).setView([20.5937, 78.9629], 4);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution:
        '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    }).addTo(map);

    return () => {
      map.remove();
    };
  }, []);

  return (
    <section className="space-y-4">
      <h2 className="text-xl font-semibold">Map Placeholder</h2>
      <p className="text-slate-700">
        Geospatial visualizations will be added in future iterations.
      </p>
      <div className="overflow-hidden rounded-lg border border-slate-200 bg-white">
        <div ref={mapRef} style={{ height: '420px', width: '100%' }} />
      </div>
    </section>
  );
}

export default MapPage;
