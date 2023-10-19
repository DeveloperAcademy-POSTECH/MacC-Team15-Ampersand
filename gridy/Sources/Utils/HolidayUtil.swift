//
//  HolidayUtil.swift
//  gridy
//
//  Created by SY AN on 2023/10/05.
//

import EventKit

 func fetchKoreanHolidays() async throws -> [Date] {
     print("=== 권한을 요청합니다.")
     let eventStore = EKEventStore()
     let isAccessed = try await isAccessPermission(store: eventStore)

     if isAccessed {
         print("=== 액세스 성공")

         let calendars = eventStore.calendars(for: .event)

         if let holidayCalendar = calendars.first(where: { $0.title == "대한민국 공휴일" }) {
             let calendar = Calendar.current
             //TODO: Holiday 받는 날짜 기준 변경하기
             let startDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 1))!
             let endDate = calendar.date(from: DateComponents(year: 2023, month: 12, day: 31))!

             let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [holidayCalendar])
             let events = eventStore.events(matching: predicate)

             // 'nil' 값을 필터링하여 'Date' 배열을 반환
             let holidays = events.compactMap { Calendar.current.startOfDay(for: $0.startDate) }

             return holidays

         } else {
             print("=== 공휴일 캘린더를 찾을 수 없습니다.")
         }

     } else {
         print("=== 권한이 거부됨")
     }

     return []
 }

 func isAccessPermission(store: EKEventStore) async throws -> Bool {
     var isRequestAccessed = false
     switch EKEventStore.authorizationStatus(for: .event) {
     case .notDetermined:
         print("EventManager: not Determined")
         // 여기서 권한 허용 팝업이 뜸!
         isRequestAccessed = try await store.requestAccess(to: .event)
     case .restricted:
         print("EventManager: restricted")
     case .denied:
         // 권한 거부 시 사용자가 직접 설정 - '앱 이름' - 캘린더 접근 허용해야 함
         print("EventManager: denied")
     case .authorized:
         print("EventManager: autorized")
         isRequestAccessed = true
     default:
         print(#fileID, #function, #line, "unknown")
     }
     return isRequestAccessed
 }
