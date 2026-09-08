package com.mrmusic.fin.ui.chat

// [T-android-split-chat] Small UI-state toggle methods extracted from
// ChatViewModel as extension functions (verbatim): tool-detail sheet,
// browser sheet, memory sheet, attachment list. The 4 backing state fields
// were flipped private->internal. No logic change.

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.compose.foundation.lazy.LazyListState
import com.mrmusic.fin.agent.Level
import com.mrmusic.fin.agent.ToolLoopDetector
import com.mrmusic.fin.browser.BrowserActionInput
import com.mrmusic.fin.browser.BrowserTabPool
import com.mrmusic.fin.data.db.MessageEntity
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Compress
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Lightbulb
import androidx.compose.material.icons.filled.Psychology
import androidx.compose.material.icons.outlined.Build
import androidx.compose.material.icons.outlined.Extension
import com.mrmusic.fin.data.BPETokenizer
import com.mrmusic.fin.data.ContextOffload
import com.mrmusic.fin.data.ContextPolicy
import com.mrmusic.fin.logging.AppLogger
import com.mrmusic.fin.data.FileMentionIndex
import com.mrmusic.fin.data.db.CompactMarkerEntity
import com.mrmusic.fin.data.model.AgentContentPart
import com.mrmusic.fin.data.model.AgentToolDefinition
import com.mrmusic.fin.data.model.LLMMessage
import com.mrmusic.fin.data.model.LLMModel
import com.mrmusic.fin.data.model.LLMStreamChunk
import com.mrmusic.fin.data.model.LLMUsage
import com.mrmusic.fin.data.model.ModelGroup
import com.mrmusic.fin.data.model.ThinkingLevel
import com.mrmusic.fin.R
import com.mrmusic.fin.data.repository.ChatRepository
import com.mrmusic.fin.data.repository.MemoryRepository
import com.mrmusic.fin.data.repository.ProviderRepository
import com.mrmusic.fin.provider.ImageBudget
import com.mrmusic.fin.provider.LLMProvider
import com.mrmusic.fin.provider.ProviderFactory
import com.mrmusic.fin.sandbox.ExecutionCoordinator
import com.mrmusic.fin.terminal.MinisOpenUrlBroker
import com.mrmusic.fin.terminal.MinisUrlMarker
import com.mrmusic.fin.tools.AgentTools
import com.mrmusic.fin.tools.FileEditTool
import com.mrmusic.fin.tools.FileReadTool
import com.mrmusic.fin.tools.FileWriteTool
import com.mrmusic.fin.tools.MemoryTools
import com.mrmusic.fin.tools.ReadImageTool
import com.mrmusic.fin.tools.ToolExecutionResult
import com.mrmusic.fin.offload.OffloadPermissionManager
import com.mrmusic.fin.service.SessionActivityTracker
import com.mrmusic.fin.service.SessionConcurrencyManager
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.yield
import org.json.JSONObject
import java.io.ByteArrayOutputStream

internal fun ChatViewModel.openToolDetail(toolBlockId: String) {
    _selectedToolDetailId.value = toolBlockId
}

internal fun ChatViewModel.closeToolDetail() {
    _selectedToolDetailId.value = null
}

internal fun ChatViewModel.toggleBrowserSheet() {
    val opening = !_showBrowserSheet.value
    if (opening) browserTabPool.ensureTabForUI()
    _showBrowserSheet.value = opening
}

internal fun ChatViewModel.dismissBrowserSheet() {
    _showBrowserSheet.value = false
}

/**
 * Open the session browser sheet, focused on the tab whose URL matches
 * [url]. If no pool tab currently has that URL, a new tab is created and
 * loaded. Used by the tool-call preview's globe button so the agent's
 * existing browser_use page is reused when available instead of spawning
 * a duplicate tab.
 */
internal fun ChatViewModel.openBrowserSheetForUrl(url: String) {
    if (url.isBlank()) {
        browserTabPool.ensureTabForUI()
    } else {
        browserTabPool.selectOrCreateTabForURL(url)
    }
    _showBrowserSheet.value = true
}

internal fun ChatViewModel.toggleMemorySheet() {
    _showMemorySheet.value = !_showMemorySheet.value
}

internal fun ChatViewModel.dismissMemorySheet() {
    _showMemorySheet.value = false
}

internal fun ChatViewModel.addAttachment(attachment: InputAttachment) {
    _attachments.value = _attachments.value + attachment
}

internal fun ChatViewModel.removeAttachment(id: String) {
    _attachments.value = _attachments.value.filter { it.id != id }
}

internal fun ChatViewModel.clearAttachments() {
    _attachments.value = emptyList()
}
