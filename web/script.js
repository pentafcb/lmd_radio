$(document).ready(function () {
    let frequencies = [];
    let currentFrequency = null;
    let playerName = "";
    let playerJob = "";
    let playerJobGrade = "";
    function playRadioSound() {
        const audio = new Audio('radio.mp3');
        audio.play().catch(err => {
            console.error("Error playing sound:", err);
        });
    }
    window.addEventListener("message", function (event) {
        if (event.data.type === "openRadio") {
            frequencies = event.data.frequencies;
            playerName = event.data.playerName;
            playerJob = event.data.job;
            playerJobGrade = event.data.jobGrade;

            buildFrequencies();
            $(".radio-container").fadeIn();

            $("#player-info").html(`
                <div class="player-info-card">
                    <span>${playerName}</span>
                    <span class="job-label">${playerJob} - ${playerJobGrade}</span>
                </div>
            `);
        }

        if (event.data.type === "updateFrequencies") {
            frequencies = event.data.frequencies;
            updateFrequenciesUI();
        }
    });
    function buildFrequencies() {
        $("#frequencies-container").empty();
        frequencies.forEach(freq => {
            const frequencyDiv = $(`
                <div class="frequency" data-id="${freq.id}" data-name="${freq.name.toLowerCase()}">
                    <div class="frequency-header">
                        <div>
                            <span class="frequency-name-box">${freq.name}</span>
                        </div>
                        <div class="actions">
                            <button class="users-btn">
                                <lord-icon
                                    src="https://cdn.lordicon.com/kdduutaw.json"
                                    trigger="loop"
                                    colors="primary:#ffffff,secondary:#ffffff"
                                    style="width:25px;height:25px;">
                                </lord-icon>
                                <span>${freq.users.length}</span>
                            </button>
                        </div>
                    </div>
                    <div class="frequency-users" style="display: ${currentFrequency === freq.id ? "block" : "none"};">
                        ${freq.users
                            .map(user => `
                                <div class="frequency-user" data-name="${user.name}" data-source="${user.source}">
                                    <img src="./images/greendot.png" alt="Online">
                                    <span>${user.name}</span>
                                    <span class="user-grade">${user.grade}</span>
                                </div>
                            `)
                            .join("")}
                    </div>
                </div>
            `);
            $("#frequencies-container").append(frequencyDiv);
        });
    }
    function updateFrequenciesUI() {
        frequencies.forEach(freq => {
            const freqDiv = $(`.frequency[data-id="${freq.id}"]`);
            if (freqDiv.length) {
                freqDiv.find(".users-btn span").text(freq.users.length);
                const usersDiv = freqDiv.find(".frequency-users");
                if (freq.users.length > 0) {
                    const userList = freq.users
                        .map(user => `
                            <div class="frequency-user" data-name="${user.name}" data-source="${user.source}">
                                <img src="./images/greendot.png" alt="Online">
                                <span>${user.name}</span>
                                <span class="user-grade">${user.grade}</span>
                            </div>
                        `)
                        .join("");
                    usersDiv.html(userList).slideDown();
                } else {
                    usersDiv.slideUp();
                }
            }
        });
    }
    $("#search-box").on("keyup", function () {
        const searchValue = $(this).val().toLowerCase();

        $(".frequency").each(function () {
            const frequencyName = $(this).data("name");
            if (frequencyName.includes(searchValue)) {
                $(this).show();
            } else {
                $(this).hide();
            }
        });
    });
    $(document).on("contextmenu", ".frequency-user", function (e) {
        e.preventDefault();
        
        if ($(".context-menu").length) {
            return;
        }
    
        const userName = $(this).data("name");
        const userSource = $(this).data("source");
        const frequencyOptions = frequencies
            .map(freq => `
                <div class="context-option move-frequency" data-id="${freq.id}" data-source="${userSource}">
                    Mover a ${freq.name}
                </div>
            `)
            .join("");
    
        const contextMenu = $(`
            <div class="context-menu" style="top: ${e.pageY}px; left: ${e.pageX}px;">
                <div class="context-option kick-user" data-name="${userName}" data-source="${userSource}">Expulsar</div>
                ${frequencyOptions}
            </div>
        `);
    
        $("body").append(contextMenu);
    });
    
    $(document).on("click", ".context-option.move-frequency", function () {
        const targetSource = $(this).data("source");
        const targetFrequency = $(this).data("id");
    
        $.post(`https://${GetParentResourceName()}/moveUser`, JSON.stringify({
            source: targetSource,
            frequency: targetFrequency
        }));
    
        $(".context-menu").remove();
    });
    
    $(document).on("click", function () {
        $(".context-menu").remove();
    });
    
    
    $(document).on("click", ".frequency", function () {
        const freqId = $(this).data("id");
        if (currentFrequency === freqId) return;

        if (currentFrequency) {
            $.post(`https://${GetParentResourceName()}/leaveFrequency`, JSON.stringify({ frequency: currentFrequency }));
            playRadioSound();
        }

        currentFrequency = freqId;
        $.post(`https://${GetParentResourceName()}/joinFrequency`, JSON.stringify({ frequency: freqId }));
        playRadioSound();
    });

    $(".power-off-card").on("click", function () {
        if (currentFrequency) {
            $.post(`https://${GetParentResourceName()}/leaveFrequency`, JSON.stringify({ frequency: currentFrequency }));
            currentFrequency = null;
            playRadioSound();
        }
    });
    
    $(document).on("keydown", function (e) {
        if (e.key === "Escape") {
            $(".radio-container").fadeOut();
            $.post(`https://${GetParentResourceName()}/closeRadio`, JSON.stringify({}));
        }
    });
    
});
