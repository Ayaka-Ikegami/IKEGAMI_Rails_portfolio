document.addEventListener("turbo:load", () => {

  const btn = document.getElementById("search-nearby-btn");

  if (btn) {
    btn.addEventListener("click", () => {
      if (!navigator.geolocation) {
        alert("このブラウザは位置情報に対応していません。");
        return;
      }

      navigator.geolocation.getCurrentPosition(
        (position) => {
          const lat = position.coords.latitude;
          const lng = position.coords.longitude;
          const radius = 1000; // デフォルト距離 = 1km

          // search_stores_path にリダイレクト
          const url = `/stores/search?lat=${lat}&lng=${lng}&radius=${radius}&keyword=うどん`;

          window.location.href = url;
        },
        (error) => {
          alert("現在地の取得に失敗しました。位置情報の利用を許可してください。");
        }
      );
    });
  }
});
