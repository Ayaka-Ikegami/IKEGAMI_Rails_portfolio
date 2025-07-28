document.addEventListener("turbo:load", () => {

  const useCurrentLocation = document.getElementById("use-current-location");
  const radiusSelect = document.getElementById("radius-select");
  const locationInput = document.getElementById("location-input");
  const keywordInput = document.querySelector("input[name='keyword']");
  const searchButton = document.getElementById("search-button");
  const resetButton = document.getElementById("reset-form");

  // 緯度経度用hidden input取得
  const latInput = document.getElementById("lat-input");
  const lngInput = document.getElementById("lng-input");

  function toggleInputs() {
    const useCurrent = useCurrentLocation.checked;
    const locationVal = locationInput.value.trim();
    const keywordVal = keywordInput.value.trim();

    // 現在地ONなら地名入力を無効化、距離選択を有効化
    locationInput.disabled = useCurrent;
    radiusSelect.disabled = !useCurrent;

    // 地名入力があれば現在地は無効に
    if (locationVal !== "") {
      useCurrentLocation.disabled = true;
      radiusSelect.disabled = true;
    } else {
      useCurrentLocation.disabled = false;
      radiusSelect.disabled = !useCurrent;
    }

    // 検索ボタン有効条件（現在地 or 地名 or キーワードのどれかが入ってる）
    if (useCurrent || locationVal !== "" || keywordVal !== "") {
      searchButton.disabled = false;
    } else {
      searchButton.disabled = true;
    }
  }

  // 現在地チェックボックス変更時の処理（緯度経度取得）
  useCurrentLocation.addEventListener("change", () => {
    if (useCurrentLocation.checked) {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
          (position) => {
            latInput.value = position.coords.latitude;
            lngInput.value = position.coords.longitude;
            toggleInputs();
          },
          (error) => {
            alert("現在地を取得できませんでした。位置情報の利用を許可してください。");
            useCurrentLocation.checked = false;
            latInput.value = "";
            lngInput.value = "";
            toggleInputs();
          }
        );
      } else {
        alert("このブラウザは位置情報に対応していません。");
        useCurrentLocation.checked = false;
        latInput.value = "";
        lngInput.value = "";
        toggleInputs();
      }
    } else {
      // チェック外したら値をクリア
      latInput.value = "";
      lngInput.value = "";
      toggleInputs();
    }
  });

  // リセットボタン処理
  resetButton?.addEventListener("click", () => {
    e.preventDefault();
    locationInput.value = "";
    keywordInput.value = "";
    useCurrentLocation.checked = false;
    radiusSelect.disabled = true ;
    latInput.value = "";
    lngInput.value = "";
    toggleInputs();
  });

  // 入力フォームの変化を監視してトグル制御
  locationInput.addEventListener("input", toggleInputs);
  keywordInput.addEventListener("input", toggleInputs);

  latInput.value = "";
  lngInput.value = "";
  toggleInputs(); // 初期化
});
