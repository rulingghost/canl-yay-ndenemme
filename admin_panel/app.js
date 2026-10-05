// Zego Live Admin Panel JS
let db = null;
let isFirebaseConnected = false;

// Mock / Yerel Veriler (Firebase bağlanana kadar tam çalışan demo mod)
let users = [
  { id: '10001', name: 'AhmetYilmaz', level: 12, coins: 45000, isBanned: false, avatar: 'https://robohash.org/10001.png?set=set4' },
  { id: '10002', name: 'ZeynepKaya', level: 8, coins: 18500, isBanned: false, avatar: 'https://robohash.org/10002.png?set=set4' },
  { id: '10003', name: 'MehmetDemir', level: 25, coins: 120000, isBanned: false, avatar: 'https://robohash.org/10003.png?set=set4' },
  { id: '10004', name: 'TrollUser', level: 1, coins: 10, isBanned: true, avatar: 'https://robohash.org/10004.png?set=set4' },
];

let activeStreams = [
  { id: 'live_78291', type: 'Canlı Video', host: 'MehmetDemir (ID: 10003)', viewers: 142 },
  { id: 'audio_44120', type: 'Sesli Sohbet Odası', host: 'AhmetYilmaz (ID: 10001)', viewers: 36 },
];

let selectedUserId = null;

// Tab Değiştirme
document.querySelectorAll('.nav-item').forEach(item => {
  item.addEventListener('click', (e) => {
    e.preventDefault();
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(s => s.classList.remove('active'));

    item.classList.add('active');
    const tabName = item.getAttribute('data-tab');
    document.getElementById(`section-${tabName}`).classList.add('active');

    // Başlık güncelle
    const titles = {
      dashboard: 'Genel Bakış & İstatistikler',
      users: 'Kullanıcı & Bakiye Yönetimi',
      streams: 'Canlı Yayın & Sesli Oda Kontrolü',
      broadcast: 'Canlı Sistem Duyurusu Gönder',
      settings: 'Google Firebase Veritabanı Yapılandırması'
    };
    document.getElementById('pageTitleText').innerText = titles[tabName] || 'Yönetim Paneli';
  });
});

// Sayfa Yüklendiğinde
window.addEventListener('DOMContentLoaded', () => {
  initFirebaseFromStorage();
  renderAll();
});

function initFirebaseFromStorage() {
  const savedConfig = localStorage.getItem('zego_firebase_config');
  if (savedConfig) {
    try {
      const config = JSON.parse(savedConfig);
      document.getElementById('firebaseConfigInput').value = savedConfig;
      if (!firebase.apps.length) {
        firebase.initializeApp(config);
      }
      db = firebase.firestore();
      isFirebaseConnected = true;

      document.getElementById('dbStatusBadge').classList.add('connected');
      document.getElementById('dbStatusText').innerText = 'Google Firebase Bağlı';

      // Firestore'dan canlı kullanıcıları dinle
      db.collection('users').onSnapshot((snapshot) => {
        if (!snapshot.empty) {
          users = [];
          snapshot.forEach(doc => {
            users.push({ id: doc.id, ...doc.data() });
          });
          renderAll();
        }
      });
    } catch (e) {
      console.error('Firebase başlatma hatası:', e);
    }
  }
}

function saveFirebaseConfig() {
  const text = document.getElementById('firebaseConfigInput').value.trim();
  try {
    const config = JSON.parse(text);
    localStorage.setItem('zego_firebase_config', text);
    alert('✅ Firebase yapılandırması başarıyla kaydedildi! Sayfa yenileniyor...');
    window.location.reload();
  } catch (e) {
    alert('❌ Geçersiz JSON formatı! Lütfen Firebase Console kodunu doğru kopyaladığınızdan emin olun.');
  }
}

// UI Çizim Fonksiyonları
function renderAll() {
  renderStats();
  renderUsersTable();
  renderStreamsTable();
}

function renderStats() {
  document.getElementById('statTotalUsers').innerText = users.length;
  const totalCoins = users.reduce((acc, u) => acc + (u.coins || 0), 0);
  document.getElementById('statTotalCoins').innerText = totalCoins.toLocaleString();
  document.getElementById('statActiveStreams').innerText = activeStreams.length;
  const bannedCount = users.filter(u => u.isBanned).length;
  document.getElementById('statBannedUsers').innerText = bannedCount;
}

function renderUsersTable() {
  const tbody = document.getElementById('usersTableBody');
  tbody.innerHTML = '';

  users.forEach(user => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>
        <div class="user-cell">
          <img src="${user.avatar || `https://robohash.org/${user.id}.png?set=set4`}" alt="avatar">
          <div>
            <strong>${user.name}</strong><br>
            <small style="color: #8c90ad;">ID: ${user.id}</small>
          </div>
        </div>
      </td>
      <td>${user.name}</td>
      <td><span class="badge badge-level">Lv.${user.level || 1}</span></td>
      <td><strong style="color: #f39c12;">🪙 ${(user.coins || 0).toLocaleString()}</strong></td>
      <td>
        <span class="badge ${user.isBanned ? 'badge-banned' : 'badge-active'}">
          ${user.isBanned ? '🚫 Banlı' : '✅ Aktif'}
        </span>
      </td>
      <td>
        <button class="btn btn-warning btn-sm" onclick="openCoinModal('${user.id}')">🪙 Coin Düzenle</button>
        <button class="btn ${user.isBanned ? 'btn-success' : 'btn-danger'} btn-sm" onclick="toggleBanUser('${user.id}')">
          ${user.isBanned ? 'Banı Kaldır' : 'Banla'}
        </button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

function renderStreamsTable() {
  const tbody = document.getElementById('streamsTableBody');
  tbody.innerHTML = '';

  activeStreams.forEach(stream => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td><strong>${stream.id}</strong></td>
      <td><span class="badge badge-level">${stream.type}</span></td>
      <td>${stream.host}</td>
      <td>👥 ${stream.viewers} İzleyici</td>
      <td>
        <button class="btn btn-danger btn-sm" onclick="stopStream('${stream.id}')">🛑 Yayını Kapat</button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

// Modal & Bakiye İşlemleri
function openCoinModal(userId) {
  selectedUserId = userId;
  const user = users.find(u => u.id === userId);
  if (!user) return;

  document.getElementById('coinModalTitle').innerText = `${user.name} - Coin Düzenle`;
  document.getElementById('coinModalUserInfo').innerText = `Mevcut Bakiye: 🪙 ${user.coins.toLocaleString()} Coin`;
  document.getElementById('coinModal').classList.add('show');
}

function closeCoinModal() {
  document.getElementById('coinModal').classList.remove('show');
}

function submitCoinChange(isAdd) {
  const amount = parseInt(document.getElementById('modalCoinAmount').value);
  if (!amount || amount <= 0) {
    alert('Geçerli bir miktar girin!');
    return;
  }

  const user = users.find(u => u.id === selectedUserId);
  if (user) {
    if (isAdd) {
      user.coins += amount;
    } else {
      user.coins = Math.max(0, user.coins - amount);
    }

    if (isFirebaseConnected && db) {
      db.collection('users').doc(user.id).set(user, { merge: true });
    }

    renderAll();
    closeCoinModal();
    alert(`İşlem Başarılı! Yeni Bakiye: 🪙 ${user.coins.toLocaleString()} Coin`);
  }
}

function quickAddCoins() {
  const userId = document.getElementById('quickUserIdInput').value.trim();
  const amount = parseInt(document.getElementById('quickCoinAmount').value);

  if (!userId || !amount) {
    alert('Lütfen kullanıcı ID ve miktar girin!');
    return;
  }

  let user = users.find(u => u.id === userId);
  if (!user) {
    // Yeni kullanıcı olarak ekle
    user = {
      id: userId,
      name: `user_${userId}`,
      level: 1,
      coins: amount,
      isBanned: false,
      avatar: `https://robohash.org/${userId}.png?set=set4`
    };
    users.push(user);
  } else {
    user.coins += amount;
  }

  if (isFirebaseConnected && db) {
    db.collection('users').doc(user.id).set(user, { merge: true });
  }

  renderAll();
  alert(`✅ ${userId} nolu kullanıcıya ${amount.toLocaleString()} Coin yüklendi!`);
  document.getElementById('quickUserIdInput').value = '';
  document.getElementById('quickCoinAmount').value = '';
}

function toggleBanUser(userId) {
  const user = users.find(u => u.id === userId);
  if (user) {
    user.isBanned = !user.isBanned;
    if (isFirebaseConnected && db) {
      db.collection('users').doc(user.id).set(user, { merge: true });
    }
    renderAll();
    alert(`Kullanıcı durumu güncellendi: ${user.isBanned ? '🚫 Banlandı' : '✅ Aktif'}`);
  }
}

function stopStream(streamId) {
  if (confirm(`${streamId} ID'li yayını zorla sonlandırmak istediğinizden emin misiniz?`)) {
    activeStreams = activeStreams.filter(s => s.id !== streamId);
    renderAll();
    alert('🛑 Yayın yönetici tarafından sonlandırıldı!');
  }
}

function sendBroadcastMessage() {
  const title = document.getElementById('broadcastTitle').value.trim();
  const msg = document.getElementById('broadcastMsg').value.trim();

  if (!title || !msg) {
    alert('Lütfen başlık ve mesaj girin!');
    return;
  }

  alert(`📢 Canlı Bildirim Gönderildi!\n\nBaşlık: ${title}\nMesaj: ${msg}\n\n(Tüm canlı yayın ve sohbet odalarına iletildi.)`);
  document.getElementById('broadcastTitle').value = '';
  document.getElementById('broadcastMsg').value = '';
}

function openNewUserModal() {
  const id = prompt('Yeni Kullanıcı ID girin (Örn: 20005):');
  if (id) {
    const name = prompt('Kullanıcı Adı:') || `user_${id}`;
    const coins = parseInt(prompt('Başlangıç Coin Miktarı:', '2500')) || 2500;

    const newUser = {
      id: id,
      name: name,
      level: 1,
      coins: coins,
      isBanned: false,
      avatar: `https://robohash.org/${id}.png?set=set4`
    };
    users.push(newUser);
    if (isFirebaseConnected && db) {
      db.collection('users').doc(id).set(newUser);
    }
    renderAll();
  }
}
