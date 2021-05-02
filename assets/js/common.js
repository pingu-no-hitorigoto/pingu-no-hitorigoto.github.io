function randerIFrame(el, obs) {
  if (obs) obs.unobserve(el);
  el.setAttribute("src", el.getAttribute("data-src"));
}
document.querySelectorAll("iframe.lazy-load").forEach(el => {
  if (window.IntersectionObserver) new IntersectionObserver(
    (entries, obs) => entries.forEach(entry => entry.isIntersecting && randerIFrame(el, obs))
  ).observe(el);
  else randerIFrame(el);
});