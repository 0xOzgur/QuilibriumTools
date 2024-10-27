#!/bin/bash

# Terminal temizleme fonksiyonu
clear_screen() {
    clear
    echo "Log Monitoring Active - Press Ctrl+C to exit"
    echo "___________________________________________________________"
}

# Global değişkenler
last_increment=""
last_change_time=$(date +%s)
last_decrease_time=$(date +%s)
CHECK_INTERVAL=5  # Kontrol aralığı (saniye)
RESTART_THRESHOLD=$((5 * 60))  # 5 dakika (saniye cinsinden)
RESTART_WAIT_TIME=$((1* 60))  # Yeniden başlatma sonrası 5 dakika bekleme
last_restart_time=0
increment_updated=""

# ANSI renk kodları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Servis yeniden başlatma fonksiyonu
restart_service() {
    local reason=$1
    echo -e "${RED}YENİDEN BAŞLATMA SEBEBİ: $reason${NC}"
    echo "Servis yeniden başlatılıyor..."
    sudo systemctl restart ceremonyclient.service
    last_restart_time=$(date +%s)
    last_change_time=$last_restart_time
    last_decrease_time=$last_restart_time
    
    echo -e "${YELLOW}Servis yeniden başlatıldı. Logların sağlıklı oluşması için 5 dakika bekleniyor...${NC}"
    for i in {300..1}; do
        echo -ne "Kalan süre: $i saniye\r"
        sleep 1
    done
    echo -e "\nBekleme süresi tamamlandı. Log analizi başlıyor..."
    sleep 2
}

# Sürekli çalışacak while döngüsü
while true; do
    clear_screen
    current_time=$(date +%s)
    increment_updated=""
    
    time_since_restart=$((current_time - last_restart_time))
    if [ $last_restart_time -ne 0 ] && [ $time_since_restart -lt $RESTART_WAIT_TIME ]; then
        remaining_wait=$((RESTART_WAIT_TIME - time_since_restart))
        echo -e "${YELLOW}Son yeniden başlatmadan bu yana $time_since_restart saniye geçti."
        echo -e "Yeni bir yeniden başlatma için $remaining_wait saniye bekleniyor...${NC}"
    else
        last_decrease=$(sudo journalctl -u ceremonyclient.service -o short-iso -n 2000 | grep 'publishing' | tail -n 20 | \
        awk -v current_time="$current_time" '
        BEGIN {
            total_time=0;
            total_decrement=0;
            count=0;
            last_decrease_gap=0;
        }
        {
            timestamp=$1;
            increment=gensub(/.*"increment":([0-9]+).*/, "\\1", "g", $0);
            cmd="date -d \"" timestamp "\" +%s";
            cmd | getline entry_time;
            close(cmd);
            
            if (previous_time && previous_increment) {
                time_gap=entry_time-previous_time;
                decrement=previous_increment-increment;
                if (decrement > 0) {
                    total_time+=time_gap;
                    total_decrement+=decrement;
                    count++;
                }
            };
            previous_time=entry_time;
            previous_increment=increment;
        }
        END {
            last_decrease_gap=(current_time - previous_time);
            printf "%d", last_decrease_gap;
        }')

        current_increment=$(sudo journalctl -u ceremonyclient.service -o short-iso -n 1 | grep 'publishing' | awk -F'"increment":' '{print $2}' | awk -F',' '{print $1}')
        
        if [ $time_since_restart -ge $RESTART_WAIT_TIME ] || [ $last_restart_time -eq 0 ]; then
            if [ ! -z "$last_decrease" ] && [ "$last_decrease" -gt "$RESTART_THRESHOLD" ]; then
                restart_service "Son düşüş $last_decrease saniye önce gerçekleşti (5 dakikadan fazla)"
                continue
            fi
            
            if [ ! -z "$current_increment" ]; then
                if [ "$current_increment" != "$last_increment" ]; then
                    last_increment=$current_increment
                    last_change_time=$current_time
                    increment_updated="${YELLOW}Increment değeri güncellendi: $current_increment${NC}"
                else
                    time_since_last_change=$((current_time - last_change_time))
                    
                    if [ $time_since_last_change -ge $RESTART_THRESHOLD ]; then
                        restart_service "Increment değeri $time_since_last_change saniyedir değişmedi"
                        continue
                    fi
                fi
            fi
        fi

        # Log analizi çıktısı
        sudo journalctl -u ceremonyclient.service -o short-iso -n 2000 | grep 'publishing' | tail -n 20 | \
        awk -v current_time="$current_time" '
        BEGIN {
            total_time=0;
            total_decrement=0;
            count=0
        }
        {
            timestamp=$1;
            increment=gensub(/.*"increment":([0-9]+).*/, "\\1", "g", $0);
            cmd="date -d \"" timestamp "\" +%s";
            cmd | getline entry_time;
            close(cmd);
            
            if (previous_time && previous_increment) {
                time_gap=entry_time-previous_time;
                decrement=previous_increment-increment;
                if (decrement > 0) {
                    total_time+=time_gap;
                    total_decrement+=decrement;
                    count++;
                    printf "Increment %s, Time Gap: %ss, Decrement: %s\n", increment, time_gap, decrement
                }
            };
            previous_time=entry_time;
            previous_increment=increment
        }
        END {
            last_decrement_gap=(current_time - previous_time);
            avg_time_per_decrement=(count > 0 && total_decrement > 0) ? total_time / total_decrement : 0;
            
            printf "___________________________________________________________\n";
            printf "Last Decrease: %s Seconds ago\n", last_decrement_gap;
        }'
        
        
        # Devam eden istatistikler
        sudo journalctl -u ceremonyclient.service -o short-iso -n 2000 | grep 'publishing' | tail -n 20 | \
        awk -v current_time="$current_time" '
        BEGIN {
            total_time=0;
            total_decrement=0;
            count=0
        }
        {
            timestamp=$1;
            increment=gensub(/.*"increment":([0-9]+).*/, "\\1", "g", $0);
            cmd="date -d \"" timestamp "\" +%s";
            cmd | getline entry_time;
            close(cmd);
            
            if (previous_time && previous_increment) {
                time_gap=entry_time-previous_time;
                decrement=previous_increment-increment;
                if (decrement > 0) {
                    total_time+=time_gap;
                    total_decrement+=decrement;
                    count++;
                }
            };
            previous_time=entry_time;
            previous_increment=increment
        }
        END {
            avg_time_per_decrement=(count > 0 && total_decrement > 0) ? total_time / total_decrement : 0;
            
            printf "Avg Publish Time per Unit Decrement: %.6f seconds\n", avg_time_per_decrement;
            printf "Time to reach 0 for your %s remaining Increments: %.2f days\n", previous_increment, (previous_increment * avg_time_per_decrement) / 86400;
            printf "___________________________________________________________\n";
            printf "Estimated time to reach 0 from different starting points:\n";
            printf "From 3,000,000: %.2f days\n", (3000000 * avg_time_per_decrement) / 86400;
            printf "From 2,500,000: %.2f days\n", (2500000 * avg_time_per_decrement) / 86400;
            printf "From 2,000,000: %.2f days\n", (2000000 * avg_time_per_decrement) / 86400;
            printf "From 1,500,000: %.2f days\n", (1500000 * avg_time_per_decrement) / 86400;
            printf "From 1,000,000: %.2f days\n", (1000000 * avg_time_per_decrement) / 86400;
            printf "From 500,000: %.2f days\n", (500000 * avg_time_per_decrement) / 86400;
            printf "From 250,000: %.2f days\n", (250000 * avg_time_per_decrement) / 86400;
        }'
    fi
    
    sleep $CHECK_INTERVAL
done