use tauri::{Manager, PhysicalPosition};

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .setup(|app| {
            if let Some(window) = app.get_webview_window("main") {
                let _ = window.center();
                if let Ok(Some(monitor)) = window.current_monitor() {
                    let size = monitor.size();
                    let win = window.outer_size().unwrap_or_default();
                    let x = (size.width.saturating_sub(win.width) / 2) as i32;
                    let y = (size.height.saturating_sub(win.height) / 2) as i32;
                    let _ = window.set_position(PhysicalPosition::new(x, y));
                }
            }
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running GTA Launcher");
}
