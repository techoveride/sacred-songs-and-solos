/**
 * ============================================================================
 * HYMN BOOK STUDIO — Modern Admin & Catalog Management Application
 * With Firebase & Master Key Authentication
 * ============================================================================
 */

(function () {
  'use strict';

  // --------------------------------------------------------------------------
  // Firebase Configuration (Matching hymn-book-690dd)
  // --------------------------------------------------------------------------
  const FIREBASE_CONFIG = {
    apiKey: "AIzaSyCHxmWSFUbVnWG5YjSpAI0MeLDdgePFWKU",
    authDomain: "hymn-book-690dd.firebaseapp.com",
    projectId: "hymn-book-690dd",
    storageBucket: "hymn-book-690dd.firebasestorage.app",
    messagingSenderId: "230343352269",
    appId: "1:230343352269:web:5fa826619b60063576ee84"
  };

  const STORAGE_KEY_AUTH_SESSION = "hymn_studio_auth_session";
  const STORAGE_KEY_AUTH_USER = "hymn_studio_auth_user";
  const STORAGE_KEY_CATALOG = "hymn_studio_catalog_v2";
  const STORAGE_KEY_VERSION = "hymn_studio_manifest_version";

  let firebaseAuth = null;

  // Initialize Firebase if library is available
  try {
    if (typeof firebase !== 'undefined' && firebase.initializeApp) {
      if (!firebase.apps.length) {
        firebase.initializeApp(FIREBASE_CONFIG);
      }
      firebaseAuth = firebase.auth();
    }
  } catch (e) {
    console.warn("Firebase initialization warning (using local fallback):", e);
  }

  // --------------------------------------------------------------------------
  // Default Starter Catalog
  // --------------------------------------------------------------------------
  const DEFAULT_CATALOG = [
    {
      id: 1203,
      title: "Great Is Thy Faithfulness",
      author: "Thomas O. Chisholm",
      tune: "default.mp3",
      version: 1,
      lyric: `1
Great is Thy faithfulness, O God my Father,
There is no shadow of turning with Thee;
Thou changest not, Thy compassions, they fail not;
As Thou hast been Thou forever wilt be.

Chorus
Great is Thy faithfulness!
Great is Thy faithfulness!
Morning by morning new mercies I see;
All I have needed Thy hand hath provided—
Great is Thy faithfulness, Lord, unto me!

2
Summer and winter, and springtime and harvest,
Sun, moon and stars in their courses above,
Join with all nature in manifold witness
To Thy great faithfulness, mercy and love.

3
Pardon for sin and a peace that endureth,
Thine own dear presence to cheer and to guide;
Strength for today and bright hope for tomorrow,
Blessings all mine, with ten thousand beside!`
    },
    {
      id: 1,
      title: "Praise, my soul, the King of heaven",
      author: "Henry Francis Lyte",
      tune: "default.mp3",
      version: 1,
      lyric: `1
Praise, my soul, the King of heaven;
To His feet thy tribute bring;
Ransomed, healed, restored, forgiven,
Who like thee His praise shall sing?
Praise Him! praise Him!
Praise the everlasting King!

2
Praise Him for His grace and favour
To our fathers in distress;
Praise Him, still the same as ever,
Slow to chide, and swift to bless:
Praise Him! praise Him!
Glorious in His faithfulness!`
    },
    {
      id: 23,
      title: "To God be the glory! great things He hath done",
      author: "Fanny J. Crosby",
      tune: "default.mp3",
      version: 1,
      lyric: `1
To God be the glory, great things He hath done!
So loved He the world that He gave us His Son,
Who yielded His life an atonement for sin,
And opened the Life-gate that all may go in.

Chorus
Praise the Lord, praise the Lord,
Let the earth hear His voice!
Praise the Lord, praise the Lord,
Let the people rejoice!
O come to the Father through Jesus the Son,
And give Him the glory, great things He hath done!`
    }
  ];

  // --------------------------------------------------------------------------
  // Application State
  // --------------------------------------------------------------------------
  let hymns = [];
  let currentHymnId = 1203;
  let manifestVersion = 2;
  let currentReaderFontSize = 15; // px
  let currentUser = null;

  // --------------------------------------------------------------------------
  // DOM References
  // --------------------------------------------------------------------------
  const elements = {
    // Auth Gateway
    authScreen: document.getElementById('authScreen'),
    mainDashboard: document.getElementById('mainDashboard'),
    emailLoginForm: document.getElementById('emailLoginForm'),
    loginEmail: document.getElementById('loginEmail'),
    loginPassword: document.getElementById('loginPassword'),
    btnLoginSubmit: document.getElementById('btnLoginSubmit'),
    loginBtnText: document.getElementById('loginBtnText'),
    loginBtnSpinner: document.getElementById('loginBtnSpinner'),
    btnGoogleSignIn: document.getElementById('btnGoogleSignIn'),
    authAlert: document.getElementById('authAlert'),
    btnTogglePwd: document.getElementById('btnTogglePwd'),
    linkCreateAdmin: document.getElementById('linkCreateAdmin'),
    rememberMe: document.getElementById('rememberMe'),

    // User Profile & Logout
    userEmailDisplay: document.getElementById('userEmailDisplay'),
    userAvatar: document.getElementById('userAvatar'),
    btnLogout: document.getElementById('btnLogout'),

    // Header & Stats
    headerManifestVer: document.getElementById('headerManifestVer'),
    headerTotalHymns: document.getElementById('headerTotalHymns'),
    btnNewHymn: document.getElementById('btnNewHymn'),
    btnImportModal: document.getElementById('btnImportModal'),
    btnExportModal: document.getElementById('btnExportModal'),
    btnGuideModal: document.getElementById('btnGuideModal'),
    btnThemeToggle: document.getElementById('btnThemeToggle'),
    iconMoon: document.getElementById('iconMoon'),
    iconSun: document.getElementById('iconSun'),

    // Sidebar
    catalogSearch: document.getElementById('catalogSearch'),
    btnClearSearch: document.getElementById('btnClearSearch'),
    catalogCount: document.getElementById('catalogCount'),
    catalogSort: document.getElementById('catalogSort'),
    hymnList: document.getElementById('hymnList'),

    // Editor Form
    editorBadge: document.getElementById('editorBadge'),
    editorCurrentTitle: document.getElementById('editorCurrentTitle'),
    hymnForm: document.getElementById('hymnForm'),
    hymnId: document.getElementById('hymnId'),
    hymnTitle: document.getElementById('hymnTitle'),
    titleCharCount: document.getElementById('titleCharCount'),
    hymnAuthor: document.getElementById('hymnAuthor'),
    hymnTune: document.getElementById('hymnTune'),
    btnPreviewTune: document.getElementById('btnPreviewTune'),
    adminAudioPreview: document.getElementById('adminAudioPreview'),
    hymnVersion: document.getElementById('hymnVersion'),
    hymnLyric: document.getElementById('hymnLyric'),
    stanzasCount: document.getElementById('stanzasCount'),
    wordCount: document.getElementById('wordCount'),
    btnInsertVerse: document.getElementById('btnInsertVerse'),
    btnInsertChorus: document.getElementById('btnInsertChorus'),
    btnFormatLyric: document.getElementById('btnFormatLyric'),
    btnDuplicateHymn: document.getElementById('btnDuplicateHymn'),
    btnDeleteHymn: document.getElementById('btnDeleteHymn'),
    btnSaveHymn: document.getElementById('btnSaveHymn'),

    // Phone Preview
    phoneMockup: document.getElementById('phoneMockup'),
    previewTitle: document.getElementById('previewTitle'),
    previewSubtitle: document.getElementById('previewSubtitle'),
    previewTune: document.getElementById('previewTune'),
    previewHymnTitle: document.getElementById('previewHymnTitle'),
    previewHymnAuthor: document.getElementById('previewHymnAuthor'),
    previewLyricsBody: document.getElementById('previewLyricsBody'),
    btnFontDecrease: document.getElementById('btnFontDecrease'),
    btnFontIncrease: document.getElementById('btnFontIncrease'),
    btnToggleSerif: document.getElementById('btnToggleSerif'),
    btnPreviewTheme: document.getElementById('btnPreviewTheme'),

    // Export Modal
    exportModal: document.getElementById('exportModal'),
    btnCloseExportModal: document.getElementById('btnCloseExportModal'),
    btnCancelExport: document.getElementById('btnCancelExport'),
    exportManifestVersion: document.getElementById('exportManifestVersion'),
    btnIncrementVer: document.getElementById('btnIncrementVer'),
    exportReleaseNotes: document.getElementById('exportReleaseNotes'),
    exportCount: document.getElementById('exportCount'),
    exportJsonCode: document.getElementById('exportJsonCode'),
    btnCopyJson: document.getElementById('btnCopyJson'),
    btnDownloadJson: document.getElementById('btnDownloadJson'),

    // Import Modal
    importModal: document.getElementById('importModal'),
    btnCloseImportModal: document.getElementById('btnCloseImportModal'),
    btnCancelImport: document.getElementById('btnCancelImport'),
    dropZone: document.getElementById('dropZone'),
    fileInput: document.getElementById('fileInput'),
    importJsonText: document.getElementById('importJsonText'),
    btnExecuteImport: document.getElementById('btnExecuteImport'),

    // Guide Modal
    guideModal: document.getElementById('guideModal'),
    btnCloseGuideModal: document.getElementById('btnCloseGuideModal'),
    btnCloseGuide: document.getElementById('btnCloseGuide'),
    guideVersionTarget: document.getElementById('guideVersionTarget'),

    // Toast
    toastContainer: document.getElementById('toastContainer')
  };

  // --------------------------------------------------------------------------
  // Authentication System
  // --------------------------------------------------------------------------
  function checkAuthentication() {
    // 1. Check if Firebase has an active session
    if (firebaseAuth) {
      firebaseAuth.onAuthStateChanged((user) => {
        if (user) {
          onLoginSuccess(user.email || 'Firebase Admin', user.photoURL);
        } else {
          // Check local stored session
          const savedSession = localStorage.getItem(STORAGE_KEY_AUTH_SESSION);
          const savedUser = localStorage.getItem(STORAGE_KEY_AUTH_USER);
          const savedPhoto = localStorage.getItem('hymn_studio_auth_photo');
          if (savedSession === 'active' && savedUser) {
            onLoginSuccess(savedUser, savedPhoto);
          } else {
            showLoginScreen();
          }
        }
      });
    } else {
      // Offline/Local check
      const savedSession = localStorage.getItem(STORAGE_KEY_AUTH_SESSION);
      const savedUser = localStorage.getItem(STORAGE_KEY_AUTH_USER);
      const savedPhoto = localStorage.getItem('hymn_studio_auth_photo');
      if (savedSession === 'active' && savedUser) {
        onLoginSuccess(savedUser, savedPhoto);
      } else {
        showLoginScreen();
      }
    }
  }

  function showLoginScreen() {
    elements.authScreen.classList.remove('hidden');
    elements.mainDashboard.classList.add('hidden');
    elements.loginEmail.focus();
  }

  function onLoginSuccess(userIdentifier, photoUrl = null) {
    currentUser = userIdentifier;
    localStorage.setItem(STORAGE_KEY_AUTH_SESSION, 'active');
    localStorage.setItem(STORAGE_KEY_AUTH_USER, userIdentifier);
    if (photoUrl) {
      localStorage.setItem('hymn_studio_auth_photo', photoUrl);
    }

    elements.userEmailDisplay.textContent = userIdentifier;

    const savedPhoto = photoUrl || localStorage.getItem('hymn_studio_auth_photo');
    if (savedPhoto) {
      elements.userAvatar.innerHTML = `<img src="${savedPhoto}" alt="Avatar">`;
    } else {
      elements.userAvatar.textContent = (userIdentifier[0] || 'A').toUpperCase();
    }

    elements.authScreen.classList.add('hidden');
    elements.mainDashboard.classList.remove('hidden');

    showToast(`Welcome back, ${userIdentifier}!`, 'success');
  }

  function logout() {
    if (firebaseAuth) {
      firebaseAuth.signOut().catch(() => {});
    }
    localStorage.removeItem(STORAGE_KEY_AUTH_SESSION);
    localStorage.removeItem(STORAGE_KEY_AUTH_USER);
    localStorage.removeItem('hymn_studio_auth_photo');
    elements.userAvatar.innerHTML = 'A';
    currentUser = null;
    showToast("You have been signed out.", "info");
    showLoginScreen();
  }

  function handleGoogleSignIn() {
    if (!firebaseAuth) {
      showAuthError("Firebase is not initialized or offline. Please use Master Key tab.");
      return;
    }

    setLoginLoading(true);
    hideAuthError();

    const provider = new firebase.auth.GoogleAuthProvider();
    provider.setCustomParameters({ prompt: 'select_account' });

    firebaseAuth.signInWithPopup(provider)
      .then((result) => {
        setLoginLoading(false);
        const user = result.user;
        onLoginSuccess(user.email, user.photoURL);
      })
      .catch((error) => {
        setLoginLoading(false);
        if (error.code === 'auth/popup-closed-by-user') {
          return;
        }
        let msg = error.message;
        if (error.code === 'auth/operation-not-allowed') {
          msg = "Google Sign-In is not enabled yet in your Firebase Console. Go to Authentication > Sign-in method and enable 'Google'.";
        } else if (error.code === 'auth/unauthorized-domain') {
          msg = `Domain not authorized. Please add '${window.location.hostname}' to Firebase Console > Authentication > Settings > Authorized domains.`;
        } else if (error.code === 'auth/operation-not-supported-in-this-environment') {
          msg = "Google popup sign-in requires running on http/https (e.g. your web hosting or localhost), not local file:// protocol.";
        }
        showAuthError(msg);
      });
  }

  function handleFirebaseLogin() {
    const email = elements.loginEmail.value.trim();
    const password = elements.loginPassword.value;

    if (!email || !password) {
      showAuthError("Please enter both email and password.");
      return;
    }

    setLoginLoading(true);
    hideAuthError();

    if (!firebaseAuth) {
      showAuthError("Firebase authentication service is unavailable. Please check your internet connection.");
      setLoginLoading(false);
      return;
    }

    firebaseAuth.signInWithEmailAndPassword(email, password)
      .then((userCredential) => {
        setLoginLoading(false);
        onLoginSuccess(userCredential.user.email);
      })
      .catch((error) => {
        setLoginLoading(false);
        let msg = "Invalid credentials. Please verify your email and password.";
        if (error.code === 'auth/operation-not-allowed') {
          msg = "Email/Password sign-in is not enabled in Firebase Console > Authentication > Sign-in method.";
        } else if (error.code === 'auth/user-not-found') {
          msg = "No user found with this email. Create the admin user in Firebase Console > Authentication > Users.";
        } else if (error.code === 'auth/wrong-password' || error.code === 'auth/invalid-credential') {
          msg = "Incorrect password. Please try again.";
        } else if (error.message) {
          msg = error.message;
        }
        showAuthError(msg);
      });
  }

  function showAuthError(msg) {
    elements.authAlert.textContent = msg;
    elements.authAlert.classList.remove('hidden');
  }

  function hideAuthError() {
    elements.authAlert.classList.add('hidden');
  }

  function setLoginLoading(loading) {
    if (loading) {
      elements.loginBtnText.classList.add('hidden');
      elements.loginBtnSpinner.classList.remove('hidden');
      elements.btnLoginSubmit.disabled = true;
    } else {
      elements.loginBtnText.classList.remove('hidden');
      elements.loginBtnSpinner.classList.add('hidden');
      elements.btnLoginSubmit.disabled = false;
    }
  }

  // --------------------------------------------------------------------------
  // Catalog Initialization & LocalStorage Persistence
  // --------------------------------------------------------------------------
  function init() {
    checkAuthentication();
    loadSavedCatalog();
    setupEventListeners();
    renderCatalogList();
    loadHymnIntoEditor(currentHymnId);
  }

  function loadSavedCatalog() {
    try {
      const savedJson = localStorage.getItem(STORAGE_KEY_CATALOG);
      const savedVer = localStorage.getItem(STORAGE_KEY_VERSION);
      if (savedJson) {
        const parsed = JSON.parse(savedJson);
        if (Array.isArray(parsed) && parsed.length > 0) {
          hymns = parsed;
        } else {
          hymns = [...DEFAULT_CATALOG];
        }
      } else {
        hymns = [...DEFAULT_CATALOG];
      }

      if (savedVer) {
        manifestVersion = parseInt(savedVer, 10) || 2;
      }
    } catch (e) {
      console.warn("Could not load from localStorage, using default catalog:", e);
      hymns = [...DEFAULT_CATALOG];
    }

    if (hymns.length > 0) {
      currentHymnId = hymns[0].id;
    }
    updateHeaderStats();
  }

  function saveCatalogToStorage() {
    try {
      localStorage.setItem(STORAGE_KEY_CATALOG, JSON.stringify(hymns));
      localStorage.setItem(STORAGE_KEY_VERSION, manifestVersion.toString());
    } catch (e) {
      console.error("Storage error:", e);
    }
    updateHeaderStats();
  }

  function updateHeaderStats() {
    elements.headerTotalHymns.textContent = hymns.length;
    elements.headerManifestVer.textContent = `v${manifestVersion}`;
    elements.guideVersionTarget.textContent = manifestVersion;
  }

  // --------------------------------------------------------------------------
  // Catalog Rendering & Filtering
  // --------------------------------------------------------------------------
  function renderCatalogList() {
    const query = elements.catalogSearch.value.trim().toLowerCase();
    const sortVal = elements.catalogSort.value;

    let filtered = hymns.filter(h => {
      if (!query) return true;
      const idMatch = h.id.toString().includes(query);
      const titleMatch = (h.title || '').toLowerCase().includes(query);
      const authorMatch = (h.author || '').toLowerCase().includes(query);
      const lyricMatch = (h.lyric || '').toLowerCase().includes(query);
      return idMatch || titleMatch || authorMatch || lyricMatch;
    });

    filtered.sort((a, b) => {
      if (sortVal === 'id-asc') return a.id - b.id;
      if (sortVal === 'id-desc') return b.id - a.id;
      if (sortVal === 'title-asc') return (a.title || '').localeCompare(b.title || '');
      return 0;
    });

    elements.catalogCount.textContent = `${filtered.length} of ${hymns.length} hymns`;
    elements.hymnList.innerHTML = '';

    if (filtered.length === 0) {
      elements.hymnList.innerHTML = `
        <div style="padding: 2rem 1rem; text-align: center; color: var(--text-muted); font-size: 0.85rem;">
          No matching hymns found.
        </div>
      `;
      return;
    }

    filtered.forEach(hymn => {
      const card = document.createElement('div');
      card.className = `hymn-card ${hymn.id === currentHymnId ? 'active' : ''}`;
      card.setAttribute('role', 'button');
      card.setAttribute('tabindex', '0');
      card.innerHTML = `
        <span class="hymn-id-badge">#${hymn.id}</span>
        <div class="hymn-card-info">
          <div class="hymn-card-title">${escapeHtml(hymn.title || 'Untitled')}</div>
          <div class="hymn-card-meta">${escapeHtml(hymn.author || 'Author unknown')}</div>
        </div>
      `;

      card.addEventListener('click', () => {
        saveCurrentFormIfModified();
        loadHymnIntoEditor(hymn.id);
      });

      elements.hymnList.appendChild(card);
    });
  }

  // --------------------------------------------------------------------------
  // Editor Form & Live Phone Preview Synchronization
  // --------------------------------------------------------------------------
  function loadHymnIntoEditor(id) {
    const hymn = hymns.find(h => h.id === id);
    if (!hymn) return;

    currentHymnId = id;
    elements.hymnId.value = hymn.id;
    elements.hymnTitle.value = hymn.title || '';
    elements.hymnAuthor.value = hymn.author || '';
    elements.hymnTune.value = hymn.tune || '';
    if (elements.adminAudioPreview && !elements.adminAudioPreview.paused) {
      elements.adminAudioPreview.pause();
    }
    if (elements.btnPreviewTune) {
      elements.btnPreviewTune.textContent = '▶ Test';
    }
    elements.hymnVersion.value = hymn.version || 1;
    elements.hymnLyric.value = hymn.lyric || '';

    elements.editorBadge.textContent = `Hymn #${hymn.id}`;
    elements.editorCurrentTitle.textContent = hymn.title || 'Untitled';
    elements.titleCharCount.textContent = `${(hymn.title || '').length} characters`;

    updateLyricStats();
    updateLivePreview();

    document.querySelectorAll('.hymn-card').forEach(card => {
      const isCardActive = card.querySelector('.hymn-id-badge').textContent === `#${id}`;
      card.classList.toggle('active', isCardActive);
    });
  }

  function updateLyricStats() {
    const text = elements.hymnLyric.value;
    const words = text.trim() ? text.trim().split(/\s+/).length : 0;
    elements.wordCount.textContent = `${words} words`;

    const stanzas = text.split(/\n\s*\n/).filter(s => s.trim().length > 0);
    elements.stanzasCount.textContent = `${stanzas.length} Stanza${stanzas.length === 1 ? '' : 's'}`;
  }

  function updateLivePreview() {
    const title = elements.hymnTitle.value.trim() || 'Untitled Hymn';
    const id = elements.hymnId.value || '0';
    const author = elements.hymnAuthor.value.trim() || 'Traditional';
    const tune = elements.hymnTune.value.trim() || 'default.mp3';
    const rawLyrics = elements.hymnLyric.value;

    elements.previewTitle.textContent = title;
    elements.previewSubtitle.textContent = `Hymn #${id}`;
    elements.previewHymnTitle.textContent = title;
    elements.previewHymnAuthor.textContent = author;
    elements.previewTune.textContent = tune;

    renderFormattedPhoneLyrics(rawLyrics);
  }

  function renderFormattedPhoneLyrics(text) {
    elements.previewLyricsBody.innerHTML = '';
    if (!text.trim()) {
      elements.previewLyricsBody.innerHTML = `
        <div style="opacity: 0.5; text-align: center; padding: 2rem 0; font-style: italic;">
          Start typing stanzas in the editor to see live mobile preview...
        </div>
      `;
      return;
    }

    const blocks = text.split(/\n\s*\n/).filter(b => b.trim().length > 0);

    blocks.forEach(block => {
      const lines = block.trim().split('\n');
      const firstLine = lines[0].trim();

      const isNumHeader = /^[0-9]+[\.\)]?$/.test(firstLine);
      const isChorus = /^chorus|refrain/i.test(firstLine);

      const blockDiv = document.createElement('div');

      if (isChorus) {
        blockDiv.className = 'phone-chorus-block';
        const contentLines = lines.slice(1);
        blockDiv.innerHTML = `
          <div class="phone-chorus-label">${escapeHtml(firstLine)}</div>
          <div>${contentLines.map(l => escapeHtml(l)).join('<br>')}</div>
        `;
      } else if (isNumHeader) {
        blockDiv.className = 'phone-verse-block';
        const contentLines = lines.slice(1);
        blockDiv.innerHTML = `
          <div class="phone-verse-num">${escapeHtml(firstLine)}</div>
          <div>${contentLines.map(l => escapeHtml(l)).join('<br>')}</div>
        `;
      } else {
        blockDiv.className = 'phone-verse-block';
        blockDiv.innerHTML = `
          <div>${lines.map(l => escapeHtml(l)).join('<br>')}</div>
        `;
      }

      elements.previewLyricsBody.appendChild(blockDiv);
    });
  }

  // --------------------------------------------------------------------------
  // Hymn Actions: Save, Create, Duplicate, Delete
  // --------------------------------------------------------------------------
  function saveCurrentHymn() {
    const id = parseInt(elements.hymnId.value, 10);
    const title = elements.hymnTitle.value.trim();
    const lyric = elements.hymnLyric.value.trim();
    const author = elements.hymnAuthor.value.trim();
    const tune = elements.hymnTune.value.trim();
    const version = parseInt(elements.hymnVersion.value, 10) || 1;

    if (!id || id <= 0) {
      showToast("Please enter a valid positive Hymn ID", "error");
      elements.hymnId.focus();
      return;
    }

    if (!title) {
      showToast("Please enter a Hymn Title", "error");
      elements.hymnTitle.focus();
      return;
    }

    if (!lyric) {
      showToast("Please provide lyrics/stanzas for this hymn", "error");
      elements.hymnLyric.focus();
      return;
    }

    const existingIndex = hymns.findIndex(h => h.id === id);
    const hymnObj = {
      id,
      title,
      author: author || null,
      tune: tune || 'default.mp3',
      lyric,
      version
    };

    if (existingIndex >= 0) {
      hymns[existingIndex] = hymnObj;
      showToast(`Saved changes to Hymn #${id}: "${title}"`, "success");
    } else {
      hymns.push(hymnObj);
      showToast(`Created new Hymn #${id}: "${title}"`, "success");
    }

    currentHymnId = id;
    saveCatalogToStorage();
    renderCatalogList();
    elements.editorBadge.textContent = `Hymn #${id}`;
    elements.editorCurrentTitle.textContent = title;
  }

  function createNewHymn() {
    saveCurrentFormIfModified();

    const maxId = hymns.reduce((max, h) => Math.max(max, h.id || 0), 0);
    const nextId = maxId > 0 ? maxId + 1 : 1204;

    const newHymn = {
      id: nextId,
      title: "New Hymn",
      author: "",
      tune: "default.mp3",
      version: 1,
      lyric: `1\nEnter first stanza here...

Chorus
Enter chorus refrain here...

2
Enter second stanza here...`
    };

    hymns.unshift(newHymn);
    currentHymnId = nextId;
    saveCatalogToStorage();
    renderCatalogList();
    loadHymnIntoEditor(nextId);
    elements.hymnTitle.focus();
    elements.hymnTitle.select();
    showToast(`Drafted new Hymn #${nextId}`, "success");
  }

  function duplicateCurrentHymn() {
    const current = hymns.find(h => h.id === currentHymnId);
    if (!current) return;

    const maxId = hymns.reduce((max, h) => Math.max(max, h.id || 0), 0);
    const nextId = maxId + 1;

    const clone = {
      ...current,
      id: nextId,
      title: `${current.title} (Copy)`,
      version: 1
    };

    hymns.push(clone);
    currentHymnId = nextId;
    saveCatalogToStorage();
    renderCatalogList();
    loadHymnIntoEditor(nextId);
    showToast(`Cloned into Hymn #${nextId}`, "success");
  }

  function deleteCurrentHymn() {
    if (hymns.length <= 1) {
      showToast("Cannot delete the last remaining hymn in the catalog", "error");
      return;
    }

    const hymn = hymns.find(h => h.id === currentHymnId);
    if (!hymn) return;

    if (!confirm(`Are you sure you want to delete Hymn #${hymn.id} ("${hymn.title}")?`)) {
      return;
    }

    hymns = hymns.filter(h => h.id !== currentHymnId);
    currentHymnId = hymns[0].id;
    saveCatalogToStorage();
    renderCatalogList();
    loadHymnIntoEditor(currentHymnId);
    showToast(`Hymn #${hymn.id} deleted`, "success");
  }

  function saveCurrentFormIfModified() {
    const id = parseInt(elements.hymnId.value, 10);
    if (!id) return;
    const existing = hymns.find(h => h.id === id);
    if (existing) {
      existing.title = elements.hymnTitle.value.trim() || existing.title;
      existing.author = elements.hymnAuthor.value.trim() || existing.author;
      existing.tune = elements.hymnTune.value.trim() || existing.tune;
      existing.version = parseInt(elements.hymnVersion.value, 10) || existing.version;
      existing.lyric = elements.hymnLyric.value || existing.lyric;
      saveCatalogToStorage();
    }
  }

  // --------------------------------------------------------------------------
  // Smart Lyric Formatter & Snippet Inserts
  // --------------------------------------------------------------------------
  function autoFormatLyrics() {
    const raw = elements.hymnLyric.value;
    if (!raw.trim()) return;

    let cleaned = raw.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
    const rawBlocks = cleaned.split(/\n\s*\n/).filter(b => b.trim().length > 0);

    const formattedBlocks = rawBlocks.map(block => {
      const lines = block.split('\n').map(l => l.trim()).filter(l => l.length > 0);
      if (lines.length === 0) return '';

      if (/^chorus|refrain/i.test(lines[0])) {
        lines[0] = 'Chorus';
      }

      return lines.join('\n');
    });

    const result = formattedBlocks.filter(b => b.length > 0).join('\n\n');
    elements.hymnLyric.value = result;
    updateLyricStats();
    updateLivePreview();
    showToast("Standardized stanzas and line breaks", "success");
  }

  function insertVerseSnippet() {
    const raw = elements.hymnLyric.value;
    const stanzas = raw.split(/\n\s*\n/).filter(s => s.trim().length > 0);
    const nextVerseNum = stanzas.length + 1;

    const snippet = `\n\n${nextVerseNum}\nEnter stanza ${nextVerseNum} lyrics here...`;
    elements.hymnLyric.value += snippet;
    updateLyricStats();
    updateLivePreview();
    elements.hymnLyric.focus();
  }

  function insertChorusSnippet() {
    const snippet = `\n\nChorus\nEnter chorus lines here...`;
    elements.hymnLyric.value += snippet;
    updateLyricStats();
    updateLivePreview();
    elements.hymnLyric.focus();
  }

  // --------------------------------------------------------------------------
  // Export Manifest & JSON Generator
  // --------------------------------------------------------------------------
  function openExportModal() {
    saveCurrentFormIfModified();

    // Automatically increase manifest version count by 1 on every export click
    manifestVersion = (parseInt(manifestVersion, 10) || 1) + 1;
    saveCatalogToStorage();
    updateHeaderStats();

    elements.exportManifestVersion.value = manifestVersion;
    elements.exportCount.textContent = hymns.length;

    renderExportJson();
    elements.exportModal.classList.remove('hidden');
    showToast(`Manifest version automatically increased to v${manifestVersion}`, "info");
  }

  function renderExportJson() {
    const ver = parseInt(elements.exportManifestVersion.value, 10) || manifestVersion;
    const notes = elements.exportReleaseNotes.value.trim() || "Catalog update";

    const exportPayload = {
      manifest_version: ver,
      notes: notes,
      hymns: hymns.map(h => ({
        id: h.id,
        title: h.title,
        author: h.author || null,
        lyric: h.lyric,
        tune: h.tune || "default.mp3",
        version: h.version || 1
      }))
    };

    const jsonString = JSON.stringify(exportPayload, null, 2);
    elements.exportJsonCode.textContent = jsonString;
  }

  function copyExportJsonToClipboard() {
    const jsonString = elements.exportJsonCode.textContent;
    navigator.clipboard.writeText(jsonString).then(() => {
      showToast("JSON copied to clipboard!", "success");
    }).catch(err => {
      showToast("Unable to copy: " + err, "error");
    });
  }

  function downloadExportJsonFile() {
    const ver = parseInt(elements.exportManifestVersion.value, 10) || manifestVersion;
    manifestVersion = ver;
    saveCatalogToStorage();
    updateHeaderStats();

    const jsonString = elements.exportJsonCode.textContent;
    const blob = new Blob([jsonString], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `hymn_updates.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);

    showToast(`Downloaded hymn_updates.json (Version ${ver})!`, "success");
    elements.exportModal.classList.add('hidden');
  }

  // --------------------------------------------------------------------------
  // Import JSON Modal & Processing
  // --------------------------------------------------------------------------
  function openImportModal() {
    elements.importJsonText.value = '';
    elements.importModal.classList.remove('hidden');
  }

  function handleFileSelect(file) {
    if (!file || !file.name.endsWith('.json')) {
      showToast("Please upload a valid .json file", "error");
      return;
    }

    const reader = new FileReader();
    reader.onload = (e) => {
      elements.importJsonText.value = e.target.result;
      showToast(`Loaded file ${file.name}`, "success");
    };
    reader.readAsText(file);
  }

  function executeImport() {
    const raw = elements.importJsonText.value.trim();
    if (!raw) {
      showToast("Please paste JSON or drop a file first", "error");
      return;
    }

    try {
      const parsed = JSON.parse(raw);
      let incomingHymns = [];
      let incomingVersion = null;

      if (Array.isArray(parsed)) {
        incomingHymns = parsed;
      } else if (parsed && typeof parsed === 'object') {
        if (parsed.manifest_version) {
          incomingVersion = parseInt(parsed.manifest_version, 10);
        }
        if (Array.isArray(parsed.hymns)) {
          incomingHymns = parsed.hymns;
        }
      }

      if (incomingHymns.length === 0) {
        showToast("No hymns array found in JSON payload", "error");
        return;
      }

      const mode = document.querySelector('input[name="importMode"]:checked').value;

      if (mode === 'replace') {
        hymns = incomingHymns.map(sanitizeHymn);
      } else {
        incomingHymns.forEach(item => {
          const sanitized = sanitizeHymn(item);
          const idx = hymns.findIndex(h => h.id === sanitized.id);
          if (idx >= 0) {
            hymns[idx] = sanitized;
          } else {
            hymns.push(sanitized);
          }
        });
      }

      if (incomingVersion && incomingVersion > manifestVersion) {
        manifestVersion = incomingVersion;
      }

      saveCatalogToStorage();
      renderCatalogList();
      if (hymns.length > 0) {
        loadHymnIntoEditor(hymns[0].id);
      }

      elements.importModal.classList.add('hidden');
      showToast(`Successfully imported ${incomingHymns.length} hymns (${mode} mode)!`, "success");
    } catch (err) {
      showToast("Failed to parse JSON: " + err.message, "error");
    }
  }

  function sanitizeHymn(raw) {
    return {
      id: parseInt(raw.id, 10) || Math.floor(Math.random() * 9000 + 1000),
      title: (raw.title || 'Untitled').toString(),
      author: raw.author ? raw.author.toString() : null,
      tune: raw.tune ? raw.tune.toString() : 'default.mp3',
      lyric: (raw.lyric || '').toString(),
      version: parseInt(raw.version, 10) || 1
    };
  }

  // --------------------------------------------------------------------------
  // Event Listeners
  // --------------------------------------------------------------------------
  function setupEventListeners() {
    // Google Sign-In & Email Submissions
    if (elements.btnGoogleSignIn) {
      elements.btnGoogleSignIn.addEventListener('click', handleGoogleSignIn);
    }

    elements.emailLoginForm.addEventListener('submit', (e) => {
      e.preventDefault();
      handleFirebaseLogin();
    });

    // Password Visibility Toggle
    elements.btnTogglePwd.addEventListener('click', () => {
      const type = elements.loginPassword.getAttribute('type') === 'password' ? 'text' : 'password';
      elements.loginPassword.setAttribute('type', type);
      elements.btnTogglePwd.textContent = type === 'password' ? '👁' : '🔒';
    });

    // Logout
    elements.btnLogout.addEventListener('click', logout);

    // Help Link
    elements.linkCreateAdmin.addEventListener('click', (e) => {
      e.preventDefault();
      alert("Admin Setup Instructions:\n\n1. In your Firebase Console (hymn-book-690dd), go to Authentication > Sign-in method.\n2. Enable 'Google' for one-click Google account login.\n3. (Optional) Enable 'Email/Password' and add your administrator user in the Users tab.\n\nOnly authorized accounts in your Firebase project can access this dashboard.");
    });

    // Header Actions
    elements.btnNewHymn.addEventListener('click', createNewHymn);
    elements.btnImportModal.addEventListener('click', openImportModal);
    elements.btnExportModal.addEventListener('click', openExportModal);
    elements.btnGuideModal.addEventListener('click', () => elements.guideModal.classList.remove('hidden'));

    // Theme Toggle
    elements.btnThemeToggle.addEventListener('click', () => {
      document.body.classList.toggle('theme-light');
      const isLight = document.body.classList.contains('theme-light');
      elements.iconMoon.classList.toggle('hidden', isLight);
      elements.iconSun.classList.toggle('hidden', !isLight);
    });

    // Sidebar Search & Sort
    elements.catalogSearch.addEventListener('input', () => {
      elements.btnClearSearch.classList.toggle('hidden', !elements.catalogSearch.value);
      renderCatalogList();
    });
    elements.btnClearSearch.addEventListener('click', () => {
      elements.catalogSearch.value = '';
      elements.btnClearSearch.classList.add('hidden');
      renderCatalogList();
    });
    elements.catalogSort.addEventListener('change', renderCatalogList);

    // Live Editor Inputs -> Preview Sync
    elements.hymnTitle.addEventListener('input', () => {
      elements.editorCurrentTitle.textContent = elements.hymnTitle.value || 'Untitled';
      elements.titleCharCount.textContent = `${elements.hymnTitle.value.length} characters`;
      updateLivePreview();
    });
    elements.hymnId.addEventListener('input', () => {
      elements.editorBadge.textContent = `Hymn #${elements.hymnId.value || '0'}`;
      updateLivePreview();
    });
    elements.hymnAuthor.addEventListener('input', updateLivePreview);
    elements.hymnTune.addEventListener('input', () => {
      if (elements.adminAudioPreview && !elements.adminAudioPreview.paused) {
        elements.adminAudioPreview.pause();
      }
      if (elements.btnPreviewTune) {
        elements.btnPreviewTune.textContent = '▶ Test';
      }
      updateLivePreview();
    });

    if (elements.btnPreviewTune && elements.adminAudioPreview) {
      elements.btnPreviewTune.addEventListener('click', () => {
        const url = (elements.hymnTune.value || '').trim();
        if (!url) {
          showToast('Please enter an MP3 tune URL to test.', 'info');
          return;
        }
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          showToast('Local asset filename entered. Only web URLs (http/https) can be streamed/tested in browser.', 'info');
          return;
        }
        if (!elements.adminAudioPreview.paused) {
          elements.adminAudioPreview.pause();
          elements.btnPreviewTune.textContent = '▶ Test';
          showToast('Audio preview paused.', 'info');
        } else {
          elements.adminAudioPreview.src = url;
          elements.adminAudioPreview.play().then(() => {
            elements.btnPreviewTune.textContent = '⏸ Stop';
            showToast('Streaming audio tune preview...', 'success');
          }).catch(err => {
            showToast('Failed to play audio stream: ' + err.message, 'error');
            elements.btnPreviewTune.textContent = '▶ Test';
          });
        }
      });

      elements.adminAudioPreview.addEventListener('ended', () => {
        elements.btnPreviewTune.textContent = '▶ Test';
      });
    }
    elements.hymnLyric.addEventListener('input', () => {
      updateLyricStats();
      updateLivePreview();
    });

    // Editor Action Buttons
    elements.btnSaveHymn.addEventListener('click', saveCurrentHymn);
    elements.btnDuplicateHymn.addEventListener('click', duplicateCurrentHymn);
    elements.btnDeleteHymn.addEventListener('click', deleteCurrentHymn);
    elements.btnFormatLyric.addEventListener('click', autoFormatLyrics);
    elements.btnInsertVerse.addEventListener('click', insertVerseSnippet);
    elements.btnInsertChorus.addEventListener('click', insertChorusSnippet);

    // Phone Reader Controls
    elements.btnFontDecrease.addEventListener('click', () => {
      if (currentReaderFontSize > 12) {
        currentReaderFontSize -= 1;
        elements.previewLyricsBody.style.fontSize = `${currentReaderFontSize}px`;
      }
    });
    elements.btnFontIncrease.addEventListener('click', () => {
      if (currentReaderFontSize < 24) {
        currentReaderFontSize += 1;
        elements.previewLyricsBody.style.fontSize = `${currentReaderFontSize}px`;
      }
    });
    elements.btnToggleSerif.addEventListener('click', () => {
      elements.phoneMockup.classList.toggle('sans-font');
    });
    elements.btnPreviewTheme.addEventListener('click', () => {
      elements.phoneMockup.classList.toggle('light-reader');
    });

    // Export Modal Events
    elements.btnCloseExportModal.addEventListener('click', () => elements.exportModal.classList.add('hidden'));
    elements.btnCancelExport.addEventListener('click', () => elements.exportModal.classList.add('hidden'));
    elements.exportManifestVersion.addEventListener('input', renderExportJson);
    elements.exportReleaseNotes.addEventListener('input', renderExportJson);
    if (elements.btnIncrementVer) {
      elements.btnIncrementVer.addEventListener('click', () => {
        let current = parseInt(elements.exportManifestVersion.value, 10) || manifestVersion;
        current += 1;
        elements.exportManifestVersion.value = current;
        manifestVersion = current;
        saveCatalogToStorage();
        updateHeaderStats();
        renderExportJson();
        showToast(`Version manually bumped to v${current}`, "info");
      });
    }
    elements.btnCopyJson.addEventListener('click', copyExportJsonToClipboard);
    elements.btnDownloadJson.addEventListener('click', downloadExportJsonFile);

    // Import Modal Events
    elements.btnCloseImportModal.addEventListener('click', () => elements.importModal.classList.add('hidden'));
    elements.btnCancelImport.addEventListener('click', () => elements.importModal.classList.add('hidden'));
    elements.btnExecuteImport.addEventListener('click', executeImport);
    elements.fileInput.addEventListener('change', (e) => {
      if (e.target.files && e.target.files[0]) {
        handleFileSelect(e.target.files[0]);
      }
    });

    // Drag and Drop
    elements.dropZone.addEventListener('dragover', (e) => {
      e.preventDefault();
      elements.dropZone.classList.add('drag-active');
    });
    elements.dropZone.addEventListener('dragleave', () => {
      elements.dropZone.classList.remove('drag-active');
    });
    elements.dropZone.addEventListener('drop', (e) => {
      e.preventDefault();
      elements.dropZone.classList.remove('drag-active');
      if (e.dataTransfer.files && e.dataTransfer.files[0]) {
        handleFileSelect(e.dataTransfer.files[0]);
      }
    });

    // Guide Modal
    elements.btnCloseGuideModal.addEventListener('click', () => elements.guideModal.classList.add('hidden'));
    elements.btnCloseGuide.addEventListener('click', () => elements.guideModal.classList.add('hidden'));

    // Keyboard Shortcuts
    document.addEventListener('keydown', (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 's') {
        e.preventDefault();
        saveCurrentHymn();
      }
      if (e.key === 'Escape') {
        elements.exportModal.classList.add('hidden');
        elements.importModal.classList.add('hidden');
        elements.guideModal.classList.add('hidden');
      }
    });
  }

  // --------------------------------------------------------------------------
  // Helper Utilities
  // --------------------------------------------------------------------------
  function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    elements.toastContainer.appendChild(toast);

    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(10px)';
      toast.style.transition = 'all 0.3s ease';
      setTimeout(() => toast.remove(), 300);
    }, 3200);
  }

  function escapeHtml(str) {
    if (!str) return '';
    return str
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  // Start Application
  window.addEventListener('DOMContentLoaded', init);
})();
