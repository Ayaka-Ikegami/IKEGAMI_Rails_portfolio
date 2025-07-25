["turbo:load", "turbo:render"].forEach((eventName) => {
document.addEventListener(eventName, () => {
  const container = document.querySelector(".star-rating");
  if (!container) return;

  const stars = container.querySelectorAll(".star");
  const hiddenInput = container.querySelector("input[type='hidden']");
  if (!hiddenInput) return;

  let selected = parseInt(container.dataset.selected) || 0;
  hiddenInput.value = selected; // 初期値をhiddenに

  const updateStars = (hovered = null) => {
    stars.forEach((star, i) => {
      star.classList.remove("hovered", "selected");
      if (hovered !== null && i < hovered) {
        star.classList.add("hovered");
      } else if (i < selected) {
        star.classList.add("selected");
      }
    });
  };

  updateStars();

  stars.forEach((star, index) => {
    star.addEventListener("mouseover", () => updateStars(index + 1));
    star.addEventListener("mouseout", () => updateStars());
    star.addEventListener("click", (e) => {
      selected = index + 1;
      hiddenInput.value = selected;
      updateStars();
      e.stopPropagation();
    });
  });

  // ★ 星以外クリックで評価をクリア（ただしフォーム内クリック除外）
  window.addEventListener("click", (e) => {
    const isClickInsideForm =
      e.target.closest(".star-rating") ||
      e.target.closest("textarea") ||
      e.target.closest("input") ||
      e.target.closest("form");

    if (!isClickInsideForm) {
      selected = 0;
      hiddenInput.value = "";
      updateStars();
    }
  });
});
});
