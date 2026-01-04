# 👨‍💻 Developer Guide - HireSphere

## 🎯 **Quick Start for Developers**

### **Understanding the Code Structure**

```
HireSphere follows a layered architecture:

┌─────────────────────────────────────┐
│         UI Layer (Pages)            │  ← What users see
├─────────────────────────────────────┤
│      Business Logic (Hooks)         │  ← Reusable logic
├─────────────────────────────────────┤
│       Service Layer (API)           │  ← API communication
├─────────────────────────────────────┤
│     Utility Layer (Auth/Utils)      │  ← Helper functions
└─────────────────────────────────────┘
```

---

## 📚 **Common Tasks**

### **1. Create a New Page**

```typescript
// app/my-new-page/page.tsx
import { Button } from "@/components/ui/button"
import { jobService } from "@/services/api.service"

export default function MyNewPage() {
  return (
    <div>
      <h1>My New Page</h1>
      <Button>Click me</Button>
    </div>
  )
}
```

**Automatic routing**: `/my-new-page`

---

### **2. Fetch Data from API**

**Option A: Using Custom Hook (Recommended)**

```typescript
import { useJobs } from "@/hooks/useData"

function JobList() {
  const { jobs, loading, error, refetch } = useJobs()
  
  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error}</div>
  
  return (
    <div>
      {jobs.map(job => (
        <JobCard key={job.id} job={job} />
      ))}
      <Button onClick={refetch}>Refresh</Button>
    </div>
  )
}
```

**Option B: Direct Service Call**

```typescript
import { jobService } from "@/services/api.service"
import { useEffect, useState } from "react"

function JobList() {
  const [jobs, setJobs] = useState<Job[]>([])
  
  useEffect(() => {
    jobService.getAll().then(setJobs)
  }, [])
  
  return <div>{/* Render jobs */}</div>
}
```

---

### **3. Create a New API Endpoint**

**Step 1: Add to service**

```typescript
// services/api.service.ts

export const jobService = {
  // Existing methods...
  
  // New method
  searchByCategory: (category: string) =>
    apiClient.get<Job[]>(`/jobs/category/${category}`),
}
```

**Step 2: Use in component**

```typescript
import { jobService } from "@/services/api.service"

const factoryJobs = await jobService.searchByCategory('factory')
```

---

### **4. Add Authentication Check**

**Option A: Component-level**

```typescript
import { ProtectedRoute } from "@/components/ProtectedRoute"

export default function SecurePage() {
  return (
    <ProtectedRoute requiredRole="EMPLOYER">
      <div>Only employers can see this</div>
    </ProtectedRoute>
  )
}
```

**Option B: Manual check**

```typescript
import { getUser, isAuthenticated, hasRole } from "@/lib/auth"

function MyComponent() {
  const user = getUser()
  
  if (!isAuthenticated()) {
    return <div>Please login</div>
  }
  
  if (!hasRole('ADMIN')) {
    return <div>Admin only</div>
  }
  
  return <div>Welcome, {user.name}!</div>
}
```

---

### **5. Handle Form Submission**

```typescript
import { useState } from "react"
import { jobService } from "@/services/api.service"
import type { CreateJobDTO } from "@/types"

function JobForm() {
  const [formData, setFormData] = useState<CreateJobDTO>({
    title: '',
    description: '',
    location: '',
    salary: '',
  })
  const [loading, setLoading] = useState(false)
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    
    try {
      const newJob = await jobService.create(formData)
      alert('Job created successfully!')
      // Reset form or redirect
    } catch (error) {
      alert('Failed to create job')
    } finally {
      setLoading(false)
    }
  }
  
  return (
    <form onSubmit={handleSubmit}>
      <Input
        value={formData.title}
        onChange={(e) => setFormData({ ...formData, title: e.target.value })}
      />
      <Button type="submit" disabled={loading}>
        {loading ? 'Creating...' : 'Create Job'}
      </Button>
    </form>
  )
}
```

---

### **6. Add a New Type**

```typescript
// types/index.ts

export interface Message {
  id: string
  senderId: string
  receiverId: string
  content: string
  createdAt: string
}

export interface CreateMessageDTO {
  receiverId: string
  content: string
}
```

Then use it:

```typescript
import type { Message, CreateMessageDTO } from "@/types"

function Chat() {
  const [messages, setMessages] = useState<Message[]>([])
  // ...
}
```

---

### **7. Use Constants Instead of Magic Strings**

**❌ Bad:**

```typescript
if (user.role === 'EMPLOYER') {
  navigate('/employer')
}
```

**✅ Good:**

```typescript
import { USER_ROLES, ROUTES } from "@/lib/constants"

if (user.role === USER_ROLES.EMPLOYER) {
  navigate(ROUTES.DASHBOARD.EMPLOYER)
}
```

---

### **8. Error Handling Best Practices**

```typescript
import { jobService } from "@/services/api.service"

async function deleteJob(jobId: string) {
  try {
    await jobService.delete(jobId)
    
    // Success
    toast.success('Job deleted successfully')
    refetchJobs()
    
  } catch (error) {
    // Error handling
    const message = error instanceof Error 
      ? error.message 
      : 'Something went wrong'
    
    toast.error(message)
    console.error('Delete job error:', error)
  }
}
```

---

### **9. Create a Reusable Component**

```typescript
// components/JobCard.tsx

import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import type { Job } from "@/types"

interface JobCardProps {
  job: Job
  onApply?: () => void
  showActions?: boolean
}

export function JobCard({ job, onApply, showActions = true }: JobCardProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>{job.title}</CardTitle>
      </CardHeader>
      <CardContent>
        <p>{job.location}</p>
        <p>{job.salary}</p>
        {showActions && (
          <Button onClick={onApply}>Apply Now</Button>
        )}
      </CardContent>
    </Card>
  )
}
```

Use it anywhere:

```typescript
import { JobCard } from "@/components/JobCard"

<JobCard 
  job={job} 
  onApply={() => applyToJob(job.id)}
  showActions={user.role === 'WORKER'}
/>
```

---

### **10. Navigate Between Pages**

```typescript
import { useRouter } from "next/navigation"
import { ROUTES } from "@/lib/constants"

function MyComponent() {
  const router = useRouter()
  
  const handleClick = () => {
    router.push(ROUTES.DASHBOARD.EMPLOYER)
  }
  
  return <Button onClick={handleClick}>Go to Dashboard</Button>
}
```

---

## 🧪 **Testing Examples**

### **Test a Component**

```typescript
import { render, screen } from '@testing-library/react'
import { JobCard } from '@/components/JobCard'

test('renders job title', () => {
  const mockJob = {
    id: '1',
    title: 'Factory Worker',
    location: 'Delhi',
    salary: '₹25,000/month',
  }
  
  render(<JobCard job={mockJob} />)
  
  expect(screen.getByText('Factory Worker')).toBeInTheDocument()
})
```

### **Test a Service**

```typescript
import { jobService } from '@/services/api.service'

// Mock fetch
global.fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    json: () => Promise.resolve([{ id: '1', title: 'Job 1' }]),
  })
)

test('fetches jobs', async () => {
  const jobs = await jobService.getAll()
  
  expect(jobs).toHaveLength(1)
  expect(jobs[0].title).toBe('Job 1')
})
```

---

## 🔧 **Debugging Tips**

### **1. Check API Responses**

```typescript
import { jobService } from "@/services/api.service"

jobService.getAll()
  .then(jobs => console.log('Jobs:', jobs))
  .catch(error => console.error('Error:', error))
```

### **2. Check Auth State**

```typescript
import { getUser, getAuthToken } from "@/lib/auth"

console.log('User:', getUser())
console.log('Token:', getAuthToken())
```

### **3. Check Constants**

```typescript
import { API_BASE_URL, API_ENDPOINTS } from "@/lib/constants"

console.log('API URL:', API_BASE_URL)
console.log('Endpoints:', API_ENDPOINTS)
```

---

## 📝

 **Code Style Guidelines**

### **Naming Conventions**

```typescript
// Components: PascalCase
export function JobCard() {}

// Functions: camelCase
function fetchJobs() {}

// Constants: UPPER_SNAKE_CASE
export const API_BASE_URL = '...'

// Types/Interfaces: PascalCase
interface User {}
type JobStatus = 'active' | 'closed'

// Files:
// - Components: JobCard.tsx
// - Services: api.service.ts
// - Hooks: useData.ts
// - Utils: auth.ts
```

### **Import Order**

```typescript
// 1. External packages
import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'

// 2. Internal components
import { Button } from '@/components/ui/button'
import { JobCard } from '@/components/JobCard'

// 3. Services and hooks
import { jobService } from '@/services/api.service'
import { useJobs } from '@/hooks/useData'

// 4. Utils and constants
import { getUser } from '@/lib/auth'
import { ROUTES } from '@/lib/constants'

// 5. Types
import type { Job, User } from '@/types'
```

---

## 🚀 **Performance Tips**

### **1. Use Custom Hooks for Data Fetching**

Custom hooks handle loading states and caching:

```typescript
const { jobs, loading } = useJobs()  // Cached!
```

### **2. Memoize Expensive Calculations**

```typescript
import { useMemo } from 'react'

const filteredJobs = useMemo(
  () => jobs.filter(job => job.location === 'Delhi'),
  [jobs]
)
```

### **3. Use Constants for Repeated Values**

```typescript
import { UI_CONFIG } from '@/lib/constants'

const pageSize = UI_CONFIG.ITEMS_PER_PAGE  // Don't hardcode 10
```

---

## 🎓 **Learning Resources**

- **Next.js App Router**: https://nextjs.org/docs/app
- **TypeScript**: https://www.typescriptlang.org/docs/
- **React Hooks**: https://react.dev/reference/react
- **SOLID Principles**: https://en.wikipedia.org/wiki/SOLID

---

## ❓ **FAQ**

### **Q: How do I add a new API endpoint?**
A: Add it to `services/api.service.ts` in the appropriate service object.

### **Q: Where do I add new pages?**
A: Create a folder in `app/` with a `page.tsx` file.

### **Q: How do I protect a page?**
A: Wrap it in `<ProtectedRoute>` component.

### **Q: Where do I add new types?**
A: Add them to `types/index.ts`.

### **Q: How do I access the current user?**
A: Use `getUser()` from `@/lib/auth`.

### **Q: How do I make API calls?**
A: Use the services from `@/services/api.service`.

---

## 🎯 **Summary**

Follow this structure:
1. Define types in `types/`
2. Create services in `services/`
3. Build hooks in `hooks/`
4. Create components in `components/`
5. Assemble pages in `app/`

**Your code will be clean, maintainable, and scalable!** 🚀
