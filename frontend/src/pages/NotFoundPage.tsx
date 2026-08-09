import { Link } from 'react-router-dom';

function NotFoundPage() {
  return (
    <section className="space-y-3">
      <h2 className="text-xl font-semibold">Page not found</h2>
      <p className="text-slate-700">The requested page does not exist.</p>
      <Link className="text-orange-700 underline" to="/">
        Return to overview
      </Link>
    </section>
  );
}

export default NotFoundPage;
